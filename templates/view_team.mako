<%inherit file='base.mako' />

<%
import datetime
def frmt_datetime(dtime):
    delta = datetime.timedelta( hours=+1 )
    dtime = dtime + delta
    return dtime.strftime("%a, %b %d %I:%M %p")
%>

<script language="javascript">
function confirmLeave(name, target)
{
  var ok = confirm('Are you sure you want to leave the team?');
  if(ok)
    location.href=target;

}
function confirmRemove(name, target)
{
  var ok = confirm('Are you sure you want to remove ' + name + ' from the team?');
  if(ok)
    location.href=target;

}
function confirmPromote(name, target)
{
  var ok = confirm('Are you sure you want to promote ' + name + ' to team captain? You will no longer be able to administer the team.');
  if(ok)
    location.href=target;

}
function confirmDelete(id)
{
  var ok = confirm('Are you sure you want to delete this team?');
  if(ok)
    location.href='/teams/'+ id + '/update?action=delete_team';

}
function confirmDeletePost(target)
{
  var ok = confirm('Are you sure you want to delete the post?');
  if(ok)
    location.href=target;

}
</script>


<%def name='title()'>${team.event.name} Team</%def>


<table align="center">
  <tr><td class="right">Team ID:</td><td>
  % if team.team_id:
    ${chapter.chapter_id}-${team.get_id()}
  % else:
    Unknown
  % endif
  </td></tr>
  <tr><td class="right">Team Chapter:</td><td>${team.chapter.name}</td></tr>
</table>

<div id="team-members">
    <h2>Members</h2>
    Maximum team size: ${team.event.team_size}
    <table class="tabular_list" align="center">
      <tr>
        <th>Name</th><th>Actions</th>
      </tr>
      % for member in team.members.all():
      <tr>
        <td>
        % if member == team.captain:
          <b>[C]</b>
        % endif
          ${member.first_name} ${member.last_name}
        </td>
        <td>
          % if member == user:
            <a onclick="confirmLeave('${member.first_name} ${member.last_name}','/teams/${team.id}/update/?action=remove_member&user_id=${member.id}')" href="javascript:void(0)">Leave</a>      
          % elif team.captain == user or user.profile.is_admin:
            <a onclick="confirmRemove('${member.first_name} ${member.last_name}','/teams/${team.id}/update/?action=remove_member&user_id=${member.id}')" href="javascript:void(0)">Remove</a>
            % if team.captain != member:
                <a onclick="confirmPromote('${member.first_name} ${member.last_name}','/teams/${team.id}/update/?action=promote_member&user_id=${member.id}')" href="javascript:void(0)">Promote</a>
            % endif
          % else:
            &nbsp;
          % endif
        </td>
      </tr>
      % endfor
    </table>
    
    <form action="/teams/${team.id}/update">
    
    % if team.members.count() >= team.event.team_size:
        <p>Team is full.</p>
    % elif team.can_invite(user):
      <p>Add member:
        <select name="user_id">
          % for u in user.__class__.objects.filter(profile__chapter=team.chapter,profile__is_member=True):
            <option value="${u.id}">${u.first_name} ${u.last_name}</option>
          % endfor
        </select>
        <input type="submit" name="action" value="Add Member">
      </p>
    % elif user in team.members.all():
        <p>You do not have permission to invite new members.</p>
    % elif not user.profile.is_member:
      <p>You cannot join teams.</p>
    % elif not team.can_join(user):
      <p>This team is not accepting new members.</p>
    % else:
      <p><a href="/teams/${team.id}/update?action=join">Join this team</a></p>
    % endif
</div>

<div id="team-board">
    % if team.can_view_board(user):
    
    <h2>Message Board</h2>
    
    <table border=1 width="100%" cellpadding=5 align="center" id="team-board-table" class="datatable">
        % if team.can_post_board(user):
            <tr>
              <td colspan="2">
                <textarea name="message" rows="2" style="width: 90%; height:auto; margin:0;"></textarea>
                <input type="submit" name="action" value="Post">
              </td>
            </tr>
        % else:
            You do not have permission to post to this board.
        % endif
    % for msg in team.posts.order_by('-date'):
      <tr>
        <td width="20%">
        <span class="name">${msg.author.first_name} ${msg.author.last_name}</span><br>
        
        <span style="font-size:0.7em; font-style:italic;">
        % if msg.author.is_superuser:
          Site Admin
        % elif team.captain == msg.author:
          Team Captain
        % elif msg.author in team.members.all():
          Team Member
        % else:
          Nonmember
        % endif
        </span><br>
          
        ${frmt_datetime(msg.date)}<br>
        % if msg.author == user or user == team.captain or user.is_superuser:
        <span style="font-size:0.75em;">
          <a href="javascript:confirmDeletePost('/teams/${team.id}/update?action=delete_post&id=${msg.id}');">Delete</a>
        </span>
        % endif
        </td>
        <td style="text-align: left;">${msg.text | h}</td>
      </tr>
    % endfor
    % if not team.posts.count():
      <tr><td colspan=2><div align="center">No posts.</div></td></tr>
    % endif
    </table>
    
    % else:
        You do not have permission to view this team's message board.
    
    % endif
</div>


% if team.captain == user or user.profile.is_admin:
<div id="team-admin">
  <h2>Administration</h2>

  <table align="center">
  
    <tr><td>
    Entry Privacy:
    </td></tr>
    <tr><td>
        <ul style="list-style-type:none;">
          <li><input type="radio" name="entry_privacy" value="0" ${'checked' if team.entry_privacy == 0 else ''}>Anyone in the chapter may join the team</li>
          <li><input type="radio" name="entry_privacy" value="2" ${'checked' if team.entry_privacy == 2 else ''}>Team members only may invite new members</li>
          <li><input type="radio" name="entry_privacy" value="3" ${'checked' if team.entry_privacy == 3 else ''}>Team captain only may invite new members</li>
        </ul>
    </td></tr>
    <tr><td>
    Board Privacy:
    </td></tr>
    <tr><td>
        <ul style="list-style-type:none;">
          <li><input type="radio" name="board_privacy" value="0" ${'checked' if team.board_privacy == 0 else ''}>Anyone in the chapter may view and post to the team message board</li>
          <li><input type="radio" name="board_privacy" value="1" ${'checked' if team.board_privacy == 1 else ''}>Anyone in the chapter may view but only team members may post to the board</li>
          <li><input type="radio" name="board_privacy" value="2" ${'checked' if team.board_privacy == 2 else ''}>Only team members may view or post to the board</li>
        </ul>
    </td></tr>
  </table>
  
    <input type="submit" name="action" value="Update Settings">
 
  <p><input id="delete_button" onclick="confirmDelete(${team.id})" type="button" value="Delete Team"></p>
  </form>
</div>
% endif
