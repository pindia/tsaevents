<%inherit file="base.mako" />
<%
from tsa.events.views import login_url
%>

<%def name="title()">Member List</%def>

<%def name="scripts()">
<script language="javascript">
function confirmSubmit()
{
    var a = $('#action_select option:selected').attr('value')
    if(a=='delete')
        return confirm('Warning: deleting users will IRREVERSIBLY DESTROY all data relating to them, including entries, teams, and team posts. Are you sure you want to delete the selected users?');
    if(a=='promote')
        return confirm('Warning: administrators have FULL CONTROL over the entire chapter, including the ability to delete users, teams, and event entries. Are you sure you want to promote the selected users to administrators?');
    if(a=='demote')
        return confirm('Normal members are able to sign up for events, but have no administrative powers. Are you sure you want to change the selected users to normal members?');
    if(a=='advisor')
        return confirm('Warning: advisor accounts have FULL CONTROL over the entire chapter just like administrators, but cannot sign up for events. Are you sure you want to change the selected users to advisors?');
    return false;
}

function confirmRemove(ename, uname, target)
{
  var ok = confirm('Are you sure you want to remove "' + ename +'" from ' + uname + '\'s events?');
  if(ok)
    location.href=target;
  return false;
}

</script>
</%def>

<br>

% if user.profile.is_admin:
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
% endif

<form action="/member_list" method="post">

<table class="tabular_list" align="center">
    <tr>
      % if user.profile.is_admin:
        <th>&nbsp;</th>
      % endif
      <th>Name</th>
      <th>Type</th>
      <!--<th>TSA ID</th>-->
      <th># E</th>
      <th># T</th>
      <th>Individual</th>
      <th>Team</th>
    </tr>
  % for member in members:
      <tr>
          % if user.profile.is_admin:
            <td><input type="checkbox" name="edit_${member.id}"></td>
          % endif
          <td>${member.first_name} ${member.last_name}</td>
          <td>
            % if member.profile.is_admin:
                Admin
            % elif member.profile.is_member:
                Member
            % else:
                Advisor
            % endif
          </td>
          <!--<td>${member.profile.indi_id or '-'}</td>-->
          <td>${member.events.count()}</td>
          <td>${member.teams.count()}</td>
          <td>|
              % for event in member.events.all():
                  ${event.short_name}
                  % if user.profile.is_admin:
                    <a href="javascript:void(0)" onclick="confirmRemove('${event.name}', '${member.first_name} ${member.last_name}', '/member_list?action=remove_event&uid=${member.id}&eid=${event.id}');">
                        <img src="/static/tsa/icons/delete.png" title="[X]">
                    </a>
                  % endif
                  |
              % endfor
          </td>
          <td>|
              % for team in member.teams.all():
                  <a href="/teams/${team.id}">${team.event.short_name}</a>|
              % endfor
          </td>
      </tr>
  % endfor
  </table>

% if user.profile.is_admin:
    <p>
        Add event to selected users:
        <!--<select name="uid">
            % for m in members:
                <option value="${m.id}">${m.first_name} ${m.last_name}</option>
            % endfor
        </select> -->
        <select name="eid">
            % for e in events:
                <option value="${e.id}">${e.name}</option>
            % endfor
        </select>        
        <input type="submit" name="action_button" value="Add Event">
    
    </p>
    <p>
        Administer Users:
        <select name="action" id="action_select">
            <option value="none"> --- Select action --- </option>
            <option value="delete">Delete selected users</option>
            <option value="promote">Change selected users to adminstrators</option>
            <option value="demote">Change selected users to normal members</option>
            <option value="advisor">Change selected users to advisors</option>
        </select>
        <input type="submit" value="Update Users" onclick="return confirmSubmit(); ">
    </p>
% endif

</form>

