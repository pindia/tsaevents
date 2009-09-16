<%inherit file='base.mako' />


<%def name='title()'>Team</%def>
<%
import datetime
def frmt_datetime(dtime):
    delta = datetime.timedelta( hours=-5 )
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


<h2>${team.event.name} Team</h2>

<table align="center">
  <tr><td class="right">Team ID:</td><td>${team.team_id or 'Unknown'}</td></tr>
  <tr><td class="right">Team Chapter:</td><td>${'11/12' if team.senior else '9/10'}</td></tr>
</table>

<h3>Members</h3>
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
      % elif team.captain == user:
        <a onclick="confirmRemove('${member.first_name} ${member.last_name}','/teams/${team.id}/update/?action=remove_member&user_id=${member.id}')" href="javascript:void(0)">Remove</a>
        <a onclick="confirmPromote('${member.first_name} ${member.last_name}','/teams/${team.id}/update/?action=promote_member&user_id=${member.id}')" href="javascript:void(0)">Promote</a>
      % else:
        &nbsp;
      % endif
    </td>
  </tr>
  % endfor
</table>

% if user in team.members.all():
  <form action="/teams/${team.id}/update">
  <p>Add member:
    <select name="user_id">
      % for u in user.__class__.objects.filter(profile__senior=team.senior,profile__is_member=True):
        <option value="${u.id}">${u.first_name} ${u.last_name}</option>
      % endfor
    </select>
    <input type="submit" name="action" value="Add Member">
  </p>
% elif team.entry_locked:
  <p>This team is not accepting new members.</p>
% else:
  <p><a href="/teams/${team.id}/update?action=join">Join this team</a></p>
% endif


<h3>Message Board</h3>

<table border=1 width="80%" cellpadding=5 align="center">
  <tr>
    <!--<td width="20%">Post:</td>-->
    <td colspan=2>
      <textarea name="message" rows=2 style="width: 90%"></textarea>
      <input type="submit" name="action" value="Post">
    </td>
  </tr>
% for msg in team.posts.order_by('-date'):
  <tr>
    <td width="20%">
    <span class="name">${msg.author.first_name} ${msg.author.last_name}</span><br>
    
    <span style="font-size:0.7em; font-style:italic;">
    % if msg.author.is_superuser:
      Site Admin
    % elif team.captain == user:
      Team Captain
    % elif user in team.members.all():
      Team Member
    % else:
      Former Member
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



% if team.captain == user:
  <h3>Administration</h3>
  % if team.entry_locked:
    <p>Team is locked: Nobody may join. <a href="/teams/${team.id}/update/?action=lock_team">Unlock</a>
  % else:
    <p>Team is unlocked: Anybody may join. <a href="/teams/${team.id}/update/?action=lock_team">Lock</a>
  % endif.
  <br>
  <input id="delete_button" onclick="confirmDelete(${team.id})" type="button" value="Delete Team">
  </form>
% endif
