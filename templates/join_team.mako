<%inherit file='base.mako' />

<%def name='title()'>Home </%def> <% %>


<h2>${event.name} Teams</h2>

% if user.teams.filter(event=event).count() != 0:
  <i>You are already in a team for this event.</i>
% else:
  <table class="tabular_list" align="center">
    <tr>
      <th>Members</th><th>Join</th>
    </tr>
    % for team in teams:
	<tr>
      <td>${team.members_list()}</td>
      <td>
      % if team.senior != user.profile.senior:
        <i>Wrong chapter</i>
      % elif team.entry_locked:
        <i>Locked</i>
      % else:
        <a href="/teams/${team.id}/update/?action=join">Join</a>
      % endif
      </td>
	</tr>
    % endfor
    % if not teams:
      <tr><td colspan="2">No teams found</td></tr>
    % endif
  </table>
  <!--Don't see your team?-->
  <form action="/join_team" method="post">
  <input type="hidden" name="event_id" value="${event.id}">
  % if event.entry_locked:
    <input type="submit" value="Cannot create new team" disabled='yes'>
  % else:
    <input type="submit" value="Create new team">
  % endif
  </form>
% endif
