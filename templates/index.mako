<%inherit file='base.mako' />

<%def name='title()'>Home</%def> <%%>
<form action="update_indi" method="post">
  <h3>Individual events:</h3>
  <table class="tabular_list" align="center">
    <tr>
      <th>Del</th><th>Name</th>
    </tr>
    % for event in user.events.all():
    <tr>
      <td><input type="checkbox" name="remove_${event.id}"></td>
      <td>${event.name}</td>
    </tr>
    % endfor
  </table>
  <p>
    Add event:
    <select>
      % for event in events.filter(is_team=False):
        <option name="${event.id}">${event.name}</option>
      % endfor
    </select>
    <input type="submit" value="Submit">
  </p>
  <h3>Teams</h3>
  <table class="tabular_list" align="center">
    <tr>
      <th>Event</th>
      <th>Members</th>
    </tr>
    % for team in user.teams.all():
    <tr>
      <td>${team.event.name}</td>
      <td>${','.join(['%s %s.' % (member.first_name, member.last_name[0]) for member in team.members.all()])}</td>
    </tr>
    % endfor
  </table>
</form>