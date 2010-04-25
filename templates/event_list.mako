<%inherit file='base.mako' />

<%def name='title()'>Event List</%def>
<%def name='render_table(events)'><%%>

<table class="tabular_list">
  <tr>
    <th>S</th>
    % if user.profile.is_admin:
      <th>Lck</th>
    % endif
    <th>Name</th>
    <th>Num</th>
    <!--<th>Reg</th>
    <th>Sta</th>
    <th>Nat</th>-->
    <th>Max</th>
    % if 'State' in chapter.name:
      <th>Rules</th>
    % endif
  </tr>
  
  <%
    import os
    import tsa.config
    rules = os.listdir(tsa.config.paths(tsa.config.STATIC_DIR, 'HSrules'))

    
  %>
  
  % for event in events:
    <%
      if MODE == 'nation' and event.max_nation == 0:
        continue
    
    
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
        % else:
          &nbsp;
        % endif
      </td>
      % if user.profile.is_admin:
      <td>
          <input type="checkbox" name="lock_${event.id}" ${'checked="true"' if event.is_locked(user) else ''}>
      </td>
      % endif
      <td>${event.name}</td>
      <td>
        % if not n:
          -
        % else:
          <a href="/${'team_list' if event.is_team else 'member_list'}/${event.id}/">${n}</a>
        % endif
      </td>
      <!--<td>${event.render_region()}</td>
      <td>${event.render_state()}</td>
      <td>${event.render_nation()}</td>-->
      <td>${rendered_max}</td>
      % if 'State' in chapter.name:
        <td>
          % if event.name.strip() + '.pdf' in rules:
            <a href="/static/tsa/HSrules/${event.name.strip()}.pdf">Rules</a>
          % else:
            -
          % endif
        </td>
      % endif
    </tr>
  % endfor
</table> 

</%def>
<%%>

<form action="/event_list" method="post">

<!--

<div align="left">
  
  <ul>
  <li>Red events are not offered at this level or have filled up and can no longer be entered.
  <li>Yellow events still have space for entry, and must be entered if you want to qualify for the next level in that event.
  <li>Green events still have space for entry, and are not required to be entered to qualify for the next level.
  </ul>
  <p>The 'Max' column shows the maximum number of people able to compete. A number in parentheses indicates that the event is only offered at the next level.</p>
</div> -->

<p>This page is currently set to display information for the ${MODE.title()} level. See the <a href="/help/member_guide#event-list">member guide</a> for details about this page.</p>


  <h2>Individual Events</h2>
  ${render_table(events.filter(is_team=False))}
  
  <h2>Team Events</h2>
  ${render_table(events.filter(is_team=True))}
  
  <input type="submit" value="Submit">
  
</form>