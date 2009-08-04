<%inherit file="base.mako" />

<%def name="title()">Member List</%def>
    
<%def name="render_list(members)">
    <table class="tabular_list" align="center">
      <tr>
        <th>Name</th>
        <th>ID</th>
        <th>Individual</th>
        <th>Team</th>
      </tr>
    % for member in members:
        <tr>
            <td>${member.first_name} ${member.last_name}</td>
            <td>${member.profile.indi_id or '-'}</td>
            <td>|
                % for event in member.events.all():
                    ${event.name}|
                % endfor
            </td>
            <td>|
                % for team in member.teams.all():
                    <a href="/teams/${team.id}">${team.event.name}</a>|
                % endfor
            </td>
        </tr>
    % endfor
    </table>
</%def>

<h3>9/10 Chapter</h3>
${render_list(members.filter(profile__senior=False))}

<h3>11/12 Chapter</h3>
${render_list(members.filter(profile__senior=True))}

<hr>
<a href="/admin/auth/user/">Edit Users</a> - <a href="/admin/events/userprofile">Edit Chapter Assignment</a>

