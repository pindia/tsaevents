<%inherit file='base.mako' />

<%def name='title()'>Team</%def> <%%>

<script language="javascript">
function confirmRemove(name, target)
{
  var ok = confirm('Confirm removal of ' + name + ' from team.');
  if(ok)
    location.href=target;

}
function confirmDelete(id)
{
  var ok = confirm('Confirm deletion of team.');
  if(ok)
    location.href='/teams/'+ id + '/update?action=delete_team';

}
</script>


<h2>${team.event.name} Team</h2>
<p>Team ID: ${team.team_id or 'Unknown'}</p>
<h3>Members</h3>
<table class="tabular_list" align="center">
  <tr>
    <th>Name</th><th>Remove</th>
  </tr>
  % for member in team.members.all():
  <tr>
    <td>${member.first_name} ${member.last_name}</td>
    <td><a onclick="confirmRemove('${member.first_name} ${member.last_name}','/teams/${team.id}/update/?action=remove_member&user_id=${member.id}')" href="javascript:void(0)">Remove</a></td>
  </tr>
  % endfor
</table>
<form action="/teams/${team.id}/update">
<p>Add member:
  <select name="user_id">
    % for u in user.__class__.objects.all():
      <option value="${u.id}">${u.first_name} ${u.last_name}</option>
    % endfor
  </select>
  <input type="submit" name="action" value="Add Member">
</p>
<h3>Administration</h3>
% if team.entry_locked:
  <p>Team is locked: Nobody may join. <a href="/teams/${team.id}/update/?action=lock_team">Unlock</a>
% else:
  <p>Team is unlocked: Anybody may join. <a href="/teams/${team.id}/update/?action=lock_team">Lock</a>
% endif.
<br>
<input id="delete_button" onclick="confirmDelete(${team.id})" type="button" value="Delete Team">
</form>
