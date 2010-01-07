<%inherit file="base.mako" />
<%
from tsa.events.views import login_url
%>

<%def name="title()">Member List</%def>

<br>

<form action="/member_list" method="get">
Filter by Event:
<select name="event">
    <option value="">-----All-----</option>
    % for event in events:
        <option value="${event.id}" ${'selected="yes"' if str(event.id) == selected_event else ''}>${event.name}</option>
    % endfor
</select>
<input type="submit" value="Filter">

</form>

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
                  ${event.short_name}|
              % endfor
          </td>
          <td>|
              % for team in member.teams.all():
                  <a href="/teams/${team.id}">${team.event.short_name}</a>|
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


