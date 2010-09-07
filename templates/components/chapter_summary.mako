
<%def name="chapter_summary(chapter, alt=False)" >

<%
if alt:
    s = "?STATEHIGH_SWITCH"
else:
    s = ''

%>

<h2>${chapter.name}</h2>

<table class="datatable" style="width:100%">

    <tr>
        <td>Members:</td>
        <td><a href="/member_list/${s}">${chapter.members.filter(is_member=True).count()}</a></td>
    </tr>
    <tr>
        <td>Teams:</td>
        <td><a href="/team_list/${s}">${chapter.teams.count()}</a></td>
    </tr>
    <tr>

        <%
        locked = chapter.locked_events.all()
        e = 0
        for event in chapter.get_events():
            if event.is_team:
              n = event.teams.filter(chapter=chapter).count()
            else:
              n = event.entrants.filter(profile__chapter=chapter).count()
            max = int(getattr(event, 'max_%s' % MODE))
            if MODE == 'region' and max == 0:
                max = event.max_state
            if max >= 0 and n > max and (event not in locked or max == 0):
                e += 1
        t = 0
        for team in chapter.teams.all():
            n = team.members.count()
            if n > team.event.team_size or n < team.event.min_team_size:
                t += 1
        %>

        % if e or t:
            <td><b>Problems:</b></td>
        % else:
            <td>Problems:</td>
        % endif
        <td>
        % if e > 0:
            <b><a href="/event_list">${e} events</a></b> &bull;
        % else:
            Events OK &bull;
        % endif
        % if t > 0:
            <b><a href="/team_list/">${t} teams</a></b>
        % else:
            Teams OK
        % endif
        </td>
    </tr>

</table>

</%def>



% if chapter.link:
    ${chapter_summary(chapter, False)}
    ${chapter_summary(chapter.link, True)}
% else:
    % if chapter.reverselink:
        ${chapter_summary(chapter.reverselink, True)}
    % endif
    ${chapter_summary(chapter, False)}
% endif