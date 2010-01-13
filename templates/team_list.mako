<%inherit file="base.mako" />

<%def name="title()">Team List</%def>


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

<form action="/team_list" method="post">
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
            % if user.profile.is_admin:
                <td><input type="entry" value="${team.team_id or ''}" name="${team.id}_id" size="5"></td>
            % else:
                <td>${team.team_id or '-'}</td>
            % endif
            <td>${team.members_list()}</td>
            <td>
                <a href="/teams/${team.id}/">View</a>
            </td>
        </tr>
    % endfor
</table>
% if user.profile.is_admin:
    <input type="submit" value="Update IDs">
% endif
</form>


% if user.is_superuser:
<a href="/admin/events/team">Edit Teams</a>
% endif