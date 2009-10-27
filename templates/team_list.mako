<%inherit file="base.mako" />

<%def name="title()">Member List</%def>


<h3>Team List</h3>

<table class="tabular_list" align="center">
    <tr>
        <th>Event</th>
        <th>Members</th>
        <th>View</th>
    </tr>
    % for team in teams:
        <tr>
            <td>${team.event.name}</td>
            <td>${team.members_list()}</td>
            <td><a href="/teams/${team.id}/">View</a></td>
        </tr>
    % endfor
</table>

% if user.is_superuser:
<a href="/admin/events/team">Edit Teams</a>
% endif