<%inherit file='base.mako' />

<%def name='title()'>Home</%def> <%%>

% if user.teams.filter(event=event).count() != 0:
  <i>You are already in a team for this event.</i>
% else:
  <table class="tabular_list" align="center">
    <tr>
      <th>Members</th><th>Join</th>
    </tr>
    % for team in teams:
      <td>${team.members_list()}</td>
      <td>
      % if team.entry_locked:
        <i>Locked</i>
      % else:
        <a href="/teams/${team.id}/update/?action=join">Join</a>
      % endif
      </td>
    % endfor
    % if not teams:
      <tr><td colspan="2">No teams found</td></tr>
    % endif
  </table>
  Don't see your team? <form action="/join_team" method="post"><input type="hidden" name="event_id" value="${event.id}"><input type="submit" value="Create new team"></form>
% endif
