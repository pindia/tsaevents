<%inherit file='base.mako' />

<%def name='title()'>Home </%def> <% %>


<h2>${event.name} Teams</h2>

% if user.teams.filter(event=event).count() != 0:
  <i>You are already in a team for this event.</i>
% else:
  <table class="tabular_list" align="center">
    <tr>
      <th>Members</th><th>View</th><th>Join</th>
    </tr>
    % for team in teams:
	<tr>
      <td>${team.members_list()}</td>
      <td>
        <a href="/teams/${team.id}/">View</a>
      </td>
      <td>
      % if team.chapter != user.profile.chapter:
        <i>Wrong chapter</i>
      % elif not team.can_join(user):
        <i>Locked</i>
      % elif team.members.count() >= team.event.team_size:
        <i>Full</i>
      % else:
        <a href="/teams/${team.id}/update/?action=join">Join</a>
      % endif
      </td>
	</tr>
    % endfor
    % if not teams:
      <tr><td colspan="3">No teams found</td></tr>
    % endif
  </table>
  <!--Don't see your team?-->
  <form action="/join_team" method="post">
  <input type="hidden" name="event_id" value="${event.id}">
  % if event.is_locked(user):
    <!--<input type="submit" value="Cannot create new team" disabled='yes'>-->
    You cannot create a new team for this event. Either it requires qualification to compete in at the current level (${MODE}), or has filled up and been locked by an administrator.
  % else:
    % if MODE == 'region' and event.max_region == 0:
      Note: This event is not offered at Regionals. You may create a team, but you will not compete until States.<br>
    % endif
    <input type="submit" value="Create new team">
  % endif
  </form>
% endif
