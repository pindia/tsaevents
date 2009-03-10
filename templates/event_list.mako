<%inherit file='base.mako' />

<%def name='title()'>Event List</%def>
<%def name='render_table(events)'><%%>

<table class="tabular_list" align="center">
  <tr>
    <th>Lock</th>
    <th>Name</th>
    <th>Num</th>
    <th>Reg</th>
    <th>Sta</th>
    <th>Nat</th>
  </tr>
  % for event in events:
    <%
      if event.is_team:
        n = event.teams.count()
      else:
        n = event.entrants.count()
      if event.max_state >= 0 and n > event.max_state:
        cellclass = 'errorback'
      else:
        cellclass = ''
      if event.max_state == -1:
        rowclass = 'redback'
      elif event.max_nation < 0:
        rowclass = 'yellowback'
      else:
        rowclass = 'greenback'
    %>
    <tr class='${rowclass}'>
      <td><a href="/event_list?action=lock_event&event_id=${event.id}">${'Yes' if event.entry_locked else 'No'}</a></td>
      <td>${event.name}</td>
      <td class='${cellclass}'>
      ${n}
      </td>
      <td>${event.render_region()}</td>
      <td>${event.render_state()}</td>
      <td>${event.render_nation()}</td>
    </tr>
  % endfor
</table> 

</%def>
<%%>
<h2>Invividual Events</h2>
${render_table(events.filter(is_team=False))}

<h2>Team Events</h2>
${render_table(events.filter(is_team=True))}