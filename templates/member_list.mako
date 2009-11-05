<%inherit file="base.mako" />
<%
from tsa.events.views import login_url
%>

<%def name="title()">Member List</%def>
    
<%def name="render_list(members)">
    <table class="tabular_list" align="center">
      <tr>
        <!--<th>ID</th>-->
        <th>Name</th>
        <th>TSA ID</th>
        <th># E</th>
        <th># T</th>
        <th>Individual</th>
        <th>Team</th>
        <th>URL</th>
      </tr>
    % for member in members:
        <tr>
            <!--<td>${member.username}</td>-->
            <td>${member.first_name} ${member.last_name}</td>
            <td>${member.profile.indi_id or '-'}</td>
            <td>${member.events.count()}</td>
            <td>${member.teams.count()}</td>
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
            <td>
                % if not user.is_superuser:
                    -
                % elif member.is_superuser:
                    -
                % else:
                    <a href="${login_url(member)}">Login</a>
                % endif
            </td>
        </tr>
    % endfor
    </table>
</%def>

<h3>9/10 Chapter</h3>
${render_list(members.filter(profile__senior=False,profile__is_member=True))}

<h3>11/12 Chapter</h3>
${render_list(members.filter(profile__senior=True,profile__is_member=True))}

% if user.is_superuser:
<!--
    <hr>
    <h3>Add User</h3>
    
    <form action="/member_list" method="POST">
    <table align="center">${ form.as_table() }</table>
    <input type="submit" value="Submit" />
    </form>
    
    <hr>
    <a href="/admin/auth/user/">Edit Users</a> - <a href="/admin/events/userprofile">Edit Chapters/TSA IDs</a>
-->
<a href='/admin/auth/user'>Edit Users</a> - <a href='/admin/events/userprofile'>Edit Chapters/IDs</a>
% endif
