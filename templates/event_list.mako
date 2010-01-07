<%inherit file='base.mako' />

<%def name='title()'>Event List</%def>
<%def name='render_table(events)'><%%>

<table class="tabular_list" align="center">
  <tr>
    <th>S</th>
    % if user.is_superuser:
      <th>Lck</th>
    % endif
    <th>Name</th>
    <th>Num</th>
    <!--<th>Reg</th>
    <th>Sta</th>
    <th>Nat</th>-->
    <th>Max</th>
  </tr>
  % for event in events:
    <%
      if event.is_team:
        n = event.teams.filter(chapter=chapter).count()
      else:
        n = event.entrants.filter(profile__chapter=chapter).count()
             
      max = getattr(event, 'max_%s' % MODE)
      if MODE == 'region' and max == 0:
        max = event.max_state
      
      rendered_max = getattr(event, 'render_%s' % MODE)()
      if MODE == 'region' and rendered_max == '-':
        rendered_max = '(' + str(event.render_state()) + ')'

        
      rowclass = 'greenback'
      if MODE == 'region' and event.max_state == -1:
        rowclass = 'yellowback'
      if MODE == 'state' and event.max_nation < 0:
        rowclass = 'yellowback'
      if event.is_locked(user):
        rowclass = 'redback'
        
    %>
    <tr class='${rowclass}'>
      <td>
        % if max > 0 and n > max:
          <img src="/static/tsa/icons/exclamation.png">
        % elif event.is_locked(user):
          <img src="/static/tsa/icons/lock.png">
        % endif
      </td>
      % if user.is_superuser:
      <td>
          <input type="checkbox" name="lock_${event.id}" ${'checked="true"' if event.is_locked(user) else ''}>
      </td>
      % endif
      <td>${event.name}</td>
      <td>
        % if not n:
          -
        % else:
          <a href="/${'team_list' if event.is_team else 'member_list'}?event=${event.id}">${n}</a>
        % endif
      </td>
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

  <p>This page is currently set to display information for the "${MODE}" level.</p>
  <ul>
  <li>Red events are not offered at this level or have filled up and can no longer be entered.
  <li>Yellow events still have space for entry, and must be entered at this level if you want to qualify for the next level of competition in that event.
  <li>Green events still have space for entry, and are not required to be entered to qualify for the next level.
  </ul>
  <p>The 'Max' column shows the maximum number of people able to compete. A number in parentheses indicates that the event is only offered at the next level.</p>
  <h2>Individual Events</h2>
  ${render_table(events.filter(is_team=False))}
  
  <h2>Team Events</h2>
  ${render_table(events.filter(is_team=True))}
  
  % if user.is_superuser:
    <input type="submit" value="Save">
      <p><a href="/admin/events/event">Edit Events</a></p>
  % endif
  
</form>