<%inherit file="base.mako" />

<%def name="title()">Team List</%def>

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

<form action="" method="post">
<table class="table table-condensed table-striped table-bordered">
    <tr>
        <!--<th>&nbsp;</th>-->
        <th>Event</th>
        % if MODE != 'nation':
            <th>TSA ID</th>
        % endif
        <th>Members</th>
    </tr>
    % for team in teams:
        <%
        n = team.members.count()
        min = team.event.min_team_size
        max = team.event.team_size
        %>
        <tr class="${cycle.next()}">
            <!--<td>
                &nbsp;
                % if n < min or n > max:
                    <img src="/static/tsa/icons/exclamation.png">
                % endif
            </td>-->
            <td><a href="/teams/${team.id}/">${team.event.name}</a></td>
            % if MODE != 'nation':
                % if user.profile.is_admin:
                    <td>${chapter.chapter_id}-<input type="entry" value="${team.get_id()}" name="${team.id}_id" size="1"></td>
                % else:
                    <td>${'%s-%s' % (chapter.chapter_id, team.get_id()) if team.team_id else '-'}</td>
                % endif
            % endif
            <td>
                ${team.members_list()}
                % if n < min:
                    <b>(Requires ${min})</b>
                % elif n > max:
                    <b>(Maximum ${max})</b>
                % endif
            </td>
        </tr>
    % endfor
    % if not teams:
        <tr><td colspan="99">No teams matching filters found. <a href="/team_list/">View all</a></td></tr>
    % endif
</table>
% if user.profile.is_admin and teams and MODE != 'nation':
    <input type="submit" value="Update IDs">
% endif
</form>
