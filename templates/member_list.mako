<%inherit file="base.mako" />

<%def name="title()">Member List</%def>
    
<table class="tabular_list" align="center">
  <tr>
    <th>Name</th>
    <th>Individual</th>
    <th>Team</th>
  </tr>
% for member in members:
    <tr>
        <td>${member.first_name} ${member.last_name}</td>
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