<%inherit file='base.mako' />

<%def name='title()'>Team</%def> <%%>

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
</script>


<h2>${team.event.name} Team</h2>
<p>
  Team Chapter: ${'11/12' if team.senior else '9/10'} <br>
  Team ID: ${team.team_id or 'Unknown'}
</p>
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
      % for u in user.__class__.objects.filter(profile__senior=team.senior):
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
