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
    <select name="add_indi_event">
        <option value="-1">----------</option>
      % for event in events.filter(is_team=False):
        <option value="${event.id}">${event.name}</option>
      % endfor
    </select>
    <input type="submit" value="Submit">
  </p>
</form>
<form action="join_team" method="get">
  <h3>Teams</h3>
  <table class="tabular_list" align="center">
    <tr>
      <th>Event</th>
      <th>Members</th>
      <th>View</th>
    </tr>
    % for team in user.teams.all():
    <tr>
      <td>${team.event.name}</td>
      <td>${team.members_list()}</td>
      <td><a href="/teams/${team.id}/">View</a></td>
    </tr>
    % endfor
  </table>
   <p>
    Create/Join Team:
    <select name="event_id">
        <option value="-1">----------</option>
      % for event in events.filter(is_team=True):
        <option value="${event.id}">${event.name}</option>
      % endfor
    </select>
    <input type="submit" value="Submit">
  </p>
</form>
