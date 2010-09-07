<!--<%! import time %>
<%def name="name(member)">${member.first_name} ${member.last_name}</%def>
<%def name="render_team(team)">
    <team id="${team.id}" event="${team.event.name}" can_join="${team.can_join(user)}" can_invite="${team.can_invite(user)}">
        <members>
            % for member in team.members.all():
                <member name="${name(member)}" captain="${team.captain == member}" />
            % endfor
        </members>
        <posts can_view="${team.can_view_board(user)}" can_post="${team.can_post_board(user)}">
            % for post in (team.posts.all() if team.can_view_board(user) else ()):
                <post author="${name(post.author)}" timestamp="${int(time.mktime(post.date.timetuple()))}">
                    ${post.text}
                </post>
            % endfor
        </posts>
    </team>
</%def>
<%def name="render_member(member)">
    <individual>
        % for event in member.events.all():
            <event name="${event.name}" />
        % endfor
    </individual>
    <teams>
        % for team in member.teams.all():
            <team id="${team.id}" />
        % endfor
    </teams>
</%def>
-->

<xml>
    <account>
        <name>${name(user)}</name>
        <chapter>${chapter.name}</chapter>
        <is_advisor>${not user.profile.is_member}</is_advisor>
        <is_admin>${user.profile.is_admin}</is_admin>
        <is_system_admin>${user.is_superuser}</is_system_admin>
    </account>
    <your_events>
        ${render_member(user)}
    </your_events>
    <member_list>
        % for member in chapter.members.all():
            <member name="${name(member.user)}">
                ${render_member(member.user)}
            </member>
        % endfor
    </member_list>
    <team_list>
        % for team in chapter.teams.all():
            ${render_team(team)}
        % endfor
    </team_list>
    <event_list mode="${MODE}">
        <individual>
            % for event in chapter.get_events().filter(is_team=False):
                <event name="${event.name}" locked="${event.is_locked(user)}"
                       n="${event.get_num(chapter)}"
                       max="${event.render_max(MODE)}"
                       is_exceeded="${event.is_exceeded(MODE, chapter)}">
                    % for member in event.entrants.filter(profile__chapter=chapter):
                        <member name="${name(member)}" />
                    % endfor
                </event>
            % endfor
        </individual>
        <team>
            % for event in chapter.get_events().filter(is_team=True):
                <event name="${event.name}" locked="${event.is_locked(user)}"
                       n="${event.get_num(chapter)}"
                       max="${event.render_max(MODE)}"
                       is_exceeded="${event.is_exceeded(MODE, chapter)}">
                    % for team in event.teams.filter(chapter=chapter):
                        <team id="${team.id}" />
                    % endfor
                </event>
            % endfor
        </team>
    </event_list>
</xml>