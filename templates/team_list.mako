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
                <td>${chapter.chapter_id}-<input type="entry" value="${team.get_id()}" name="${team.id}_id" size="1"></td>
            % else:
                <td>${'%s-%s' % (chapter.chapter_id, team.get_id()) if team.team_id else '-'}</td>
            % endif
            <td>${team.members_list()}</td>
            <td>
                <a href="/teams/${team.id}/">View</a>
            </td>
        </tr>
    % endfor
    % if not teams:
        <tr><td colspan="99">No teams matching filters found. <a href="/team_list/">View all</a></td></tr>
    % endif
</table>
% if user.profile.is_admin and teams:
    <input type="submit" value="Update IDs">
% endif
</form>