<%inherit file="layout.mako" />


<%def name="header()">
  <div id="infobar" class="span-24 last">
    Logged in as ${user.first_name} ${user.last_name} (${user.username})
    % if user.profile.is_admin:
      <b>[A]</b>
    % elif hasattr(user,'admin_disabled'):
      <i>[<a href="?ENABLE_ADMIN">E</a>]</i>
    % endif
    |
    ${user.profile.chapter}
    % if not user.profile.is_member:
      (N)
    % endif
    % if user.profile.chapter and user.profile.chapter.name.startswith('State High') and user.is_superuser:
      [<a href="?STATEHIGH_SWITCH">Switch</a>]
    % endif
    |
    Events: ${user.events.all().count()} Teams: ${user.teams.all().count()}
    |
    <a href="/help">Help</a>
    &bull;
    <a href="/settings">Settings</a>
    &bull;
    <a href="/accounts/logout">Logout</a>
  </div>
</%def>

<div id="navigation-container" class="span-4">
  <div id="navigation" class="datatable">
    <h2>Navigation</h2>
    <ul class="text">
      % if user.profile.chapter:
        <li> <a href='/'>Your&nbsp;Events</a></li>
        <li> <a href='/event_list'>Event&nbsp;List</a></li>
        <li> <a href='/member_list/'>Member&nbsp;List</a></li>
        <li> <a href='/team_list/'>Team&nbsp;List</a></li>
      % endif
      % if user.profile.chapter and user.profile.is_admin:
      <li> Chapter&nbsp;Admin
        <ul>
          <li> <a href='/event_log?type=chapter'>Chapter&nbsp;Log</a></li>
          <li> <a href='/edit_chapter?type=chapter'>Edit&nbsp;Chapter</a></li>
          <li> <a href='/member_fields'>Member&nbsp;Fields</a></li>
        </ul>
      </li>
      % endif
      % if user.is_superuser:
      <li> System&nbsp;Admin
        <ul>
          <li> <a href='/event_log?type=system'>System&nbsp;Log</a></li>
          <li> <a href='/config/chapter_list'>Chapter&nbsp;List</a></li>
          <li> <a href='/config/eventsets/'>Event&nbsp;Sets</a></li>
        </ul>
      </li>
      % endif
    </ul>
  </div>
</div>

<div id="body" class="span-20 last" align="center">
  <h1>TSA Events - ${self.title()}</h1>
  % if messages:
    % for message in messages:
      <div align="center" class="${'error' if message.startswith('Error:') else 'info'}">${message}</div>
    % endfor
  % endif
  ${next.body()}
</div>

<%def name="footer()">
${parent.footer()}
% if not DEPLOYED:
  <div align="center">${len(connection.queries)} SQL queries executed</div>
  <!--<ol>
  % for query in connection.queries:
    <li>${query['sql']}</li>
  % endfor
  </ol>-->
% endif
</%def>

