<%inherit file='base.mako' />

<%def name='title()'>Team</%def> <%%>

<h2>${team.event.name} Team</h2>
<table class="tabular_list" align="center">
  <tr>
    <th>Name</th><th>Remove</th>
  </tr>
  % for member in team.members.all():
  <tr>
    <td>${member.first_name} ${member.last_name}</td>
    <td><a href="/teams/${team.id}/update/?action=remove_member&user_id=${member.id}">Remove</a></td>
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
  <input type="hidden" name="action" value="add_member">
  <input type="submit" value="Add">
</p>
</form>
% if team.entry_locked:
  <p>Team is locked: Nobody may join. <a href="/teams/${team.id}/update/?action=lock_team">Unlock</a>
% else:
  <p>Team is unlocked: Anybody may join. <a href="/teams/${team.id}/update/?action=lock_team">Lock</a>
% endif.