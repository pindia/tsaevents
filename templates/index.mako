<%inherit file='base.mako' />

<%def name='title()'>Home</%def> <%%>


% if chapter.message:
<p>${chapter.message | h}</p>
% endif


% if user.profile.is_member:

<script language="javascript">

function confirmRemove(name, target)
{
  var ok = confirm('Are you sure you want to remove "' + name +'" from your events?');
  if(ok)
    location.href=target;
}

</script>

<p>
% if user.profile.indi_id:
  Your individual ID is: ${chapter.chapter_id}-${user.profile.get_id()}
% endif
</p>



<form action="update_indi" method="post">
  <h3>Individual events:</h3>
  <table class="tabular_list" align="center">
    <tr>
      <th>&nbsp;</th><th>Event</th><th>Del</th>
    </tr>
    % for event in user.events.all():
    <tr class="${cycle.next()}">
      <td><img src="/static/tsa/icons/user.png" title="Individual"></td>
      <td>${event.name}</td>
      <td><a onclick="confirmRemove('${event.name}','/update_indi?delete_event=${event.id}')" href="javascript:void(0)"><img src="/static/tsa/icons/delete.png" title="Remove Event"></a></td>
    </tr>
    % endfor
  </table>
  <p>
    Add event:
    <select name="add_indi_event">
        <option value="-1">----------</option>
      % for event in chapter.get_events().filter(is_team=False):
        <option ${"disabled='yes'" if event.is_locked(user) else ''} value="${event.id}">${event.name}</option>
      % endfor
    </select>
    <input type="submit" value="Submit">
  </p>
</form>
<form action="join_team" method="get">
  <h3>Teams</h3>
  <table class="tabular_list" align="center">
    <tr>
      <th>&nbsp;</th>
      <th>Event</th>
      <th>Members</th>
      <th>View</th>
    </tr>
    % for team in user.teams.all():
    <tr class="${cycle.next()}">
      <td><img src="/static/tsa/icons/group.png" title="Team"></td>
      <td>${team.event.name}</td>
      <td>${team.members_list()}</td>
      <td><a href="/teams/${team.id}/">View</a></td>
    </tr>
    % endfor
  </table>
   <p>
    Create/Join Team:
    <select name="event_id">
        <option value="-1">----------</option>
      % for event in chapter.get_events().filter(is_team=True):
        <option value="${event.id}">${event.name}</option>
      % endfor
    </select>
    <input type="submit" value="Submit">
  </p>
</form>

% else:
You cannot sign up for events because you are a chapter advisor. 
% endif
