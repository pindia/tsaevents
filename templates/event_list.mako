<%inherit file='base.mako' />

<%def name='title()'>Event List</%def>
<%def name='render_table(events)'><%%>

<table class="tabular_list" align="center">
  <tr>
    <th>Lock</th>
    <th>Name</th>
    <th>9/10</th>
    <th>11/12</th>
    <!--<th>Reg</th>
    <th>Sta</th>
    <th>Nat</th>-->
    <th>Max</th>
  </tr>
  % for event in events:
    <%
      if event.is_team:
        n = [event.teams.filter(senior=False).count(),
             event.teams.filter(senior=True).count()]
      else:
        n = [event.entrants.filter(profile__senior=False).count(),
             event.entrants.filter(profile__senior=True).count()]
             
      max = getattr(event, 'max_%s' % MODE)
      rendered_max = getattr(event, 'render_%s' % MODE)()

      '''cellclass[0] = 'errorback' is event.max_state
      if event.max_state >= 0 and n[0] > event.max_state:
        cellclass = 'errorback'
      else:
        cellclass = '' '''
        
      rowclass = 'greenback'
      if MODE == 'region' and event.max_state == -1:
        rowclass = 'yellowback'
      if MODE == 'state' and event.max_nation < 0:
        rowclass = 'yellowback'
      if event.entry_locked:
        rowclass = 'redback'
        
    %>
    <tr class='${rowclass}'>
      <!--<td><a href="/event_list?action=lock_event&event_id=${event.id}">${'Yes' if event.entry_locked else 'No'}</a></td>-->
      <td>
        % if user.is_superuser:
          <input type="checkbox" name="lock_${event.id}" ${'checked="true"' if event.entry_locked else ''}>
        % else:
          ${'<img src="/static/tsa/icons/lock.png">' if event.entry_locked else '-'}
        % endif
      </td>
      <td>${event.name}</td>
      <td>${n[0]}</td>
      <td>${n[1]}</td>
      <!--<td>${event.render_region()}</td>
      <td>${event.render_state()}</td>
      <td>${event.render_nation()}</td>-->
      <td>${rendered_max}</td>
    </tr>
  % endfor
</table> 

</%def>
<%%>

<form action="/event_list" method="post">

  <h2>Individual Events</h2>
  ${render_table(events.filter(is_team=False))}
  
  <h2>Team Events</h2>
  ${render_table(events.filter(is_team=True))}
  
  % if user.is_superuser:
    <input type="submit" value="Save">
  % endif
  
</form>