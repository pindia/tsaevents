
<script language="javascript">

function confirmRemove(name, target)
{
  var ok = confirm('Are you sure you want to remove "' + name +'" from your events?');
  if(ok)
    location.href=target;
}

</script>

<h2>Your Events</h2>

<form action="update_indi" method="post">
<h3>Individual</h3>
<table class="table table-condensed table-striped" align="center" style="width:100%; margin:0px">
  <tr>
    <th>Event</th><th>&nbsp;</th>
  </tr>
  % for event in user.events.all():
  <tr class="${cycle.next()}">
    <!--<td>
      % if event.is_locked(user):
        <img src="/static/tsa/icons/user-tick.png" title="Individual">
      % elif event.is_exceeded(MODE, chapter):
        <img src="/static/tsa/icons/user-exclamation.png" title="Individual">
      % else:
        <img src="/static/tsa/icons/user.png" title="Individual">
      % endif
    </td>-->
    <td>${event.name}</td>
    <td><a onclick="confirmRemove('${event.name}','/update_indi?delete_event=${event.id}')" href="javascript:void(0)"><i class="icon-remove" title="Remove Event"></i></a></td>
  </tr>
  % endfor
</table>
<div class="form-inline" style="margin-top: 5px;">
  <select name="add_indi_event">
      <option value="-1">--- Add individual event ---</option>
    % for event in chapter.get_events().filter(is_team=False):
      <option ${"disabled='yes'" if event.is_locked(user) else ''} value="${event.id}">${event.name}</option>
    % endfor
  </select>
  <input type="submit" value="Submit" class="btn">
</div>
</form>
<form action="join_team" method="get">
<h3>Team</h3>
<table class="table table-condensed table-striped" align="center" style="width:100%; margin:0px">
  <tr>
    <th>Event</th>
    <th>Members</th>
  </tr>
  % for team in user.teams.all():
  <tr class="${cycle.next()}">
    <!--<td>
      % if team.event.is_locked(user):
        <img src="/static/tsa/icons/group-tick.png" title="Team">
      % elif team.event.is_exceeded(MODE, chapter):
        <img src="/static/tsa/icons/group-exclamation.png" title="Team">
      % else:
        <img src="/static/tsa/icons/group.png" title="Team">
      % endif
    </td>-->
    <td>  <a href="/teams/${team.id}/">${team.event.name}</a></td>
    <td>
      ${team.members_list('<br>')}
      % if team.members.count() < team.event.min_team_size:
          <br><span class="label label-important">Requires&nbsp;${team.event.min_team_size}</span>
      % endif
    </td>
  </tr>
  </a>
  % endfor
</table>
<div class="form-inline" style="margin-top: 5px;">
  <select name="event_id">
      <option value="-1">--- Create or join team ---</option>
    % for event in chapter.get_events().filter(is_team=True):
      <option value="${event.id}">${event.name}</option>
    % endfor
  </select>
  <input type="submit" value="Submit" class="btn">
</div>
</form>