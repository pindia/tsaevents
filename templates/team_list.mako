<%inherit file="base.mako" />

<%def name="title()">Team List</%def>


<%def name="render_list(teams)">

<table class="tabular_list" align="center">
    <tr>
        <th>Event</th>
        <th>TSA ID</th>
        <th>Members</th>
        <th>View</th>
    </tr>
    % for team in teams:
        <tr>
            <td>${team.event.name}</td>
            <td>${team.team_id or '-'}</td>
            <td>${team.members_list()}</td>
            <td>
            % if team.entry_locked:
                <i>Private</i>
            % else:
                <a href="/teams/${team.id}/">View</a>
            % endif
            </td>
        </tr>
    % endfor
</table>

</%def>

<br>

<form action="/team_list" method="get">
Filter by Event:
<select name="event">
    <option value="">-----All-----</option>
    % for event in events:
        <option value="${event.id}" ${'selected="yes"' if str(event.id) == selected_event else ''}>${event.name}</option>
    % endfor
</select>
<input type="submit" value="Filter">
</form>


<h3>9/10 Chapter</h3>
${render_list(teams.filter(senior=False))}

<h3>11/12 Chapter</h3>
${render_list(teams.filter(senior=True))}


% if user.is_superuser:
<a href="/admin/events/team">Edit Teams</a>
% endif