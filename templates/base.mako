<%inherit file="layout.mako" />


<%def name="header()">
    Logged in as ${user.first_name} ${user.last_name} (${user.username})
    % if user.is_superuser:
      <b>[SA]</b>
    % elif user.profile.is_admin:
      <b>[A]</b>
    % endif
    &bull;
    ${user.profile.chapter}
    % if not user.profile.is_member:
      (N)
    % endif
    % if user.profile.chapter and (user.profile.chapter.link or user.profile.chapter.reverselink) and user.profile.is_admin:
      [<a href="?SWITCH_CHAPTER">Switch</a>]
    % endif
    &bull;
    Events: ${user.events.all().count()} Teams: ${user.teams.all().count()}
    &bull;
    <a href="/help">Help</a>
    &bull;
    <a href="/settings">Settings</a>
    &bull;
    <a href="/accounts/logout">Logout</a>
</%def>

<div class="row">

    <div id="navigation-container" class="span2">
      <div id="navigation" class="datatable">
        <ul class="nav nav-list">
          <li class="nav-header">Navigation</li>
          % if user.profile.chapter:
            <li> <a href='/'><i class="icon-home"></i>Home</a></li>
            <li> <a href='/event_list'><i class="icon-book"></i>Event&nbsp;List</a></li>
            <li> <a href='/member_list/'><i class="icon-user"></i>Member&nbsp;List</a></li>
            <li> <a href='/team_list/'><i class="icon-th-list"></i>Team&nbsp;List</a></li>
          % endif
          % if user.profile.chapter and user.profile.is_admin:
          <li class="nav-header"> Chapter&nbsp;Admin</li>
              <li> <a href='/member_fields'><i class="icon-list-alt"></i>Fields</a></li>
              <li> <a href='/attendance'><i class="icon-check"></i>Attendance</a></li>
              <li> <a href='/email'><i class="icon-envelope"></i>Email</a></li>
              <li> <a href='/event_log?type=chapter'><i class="icon-info-sign"></i>Chapter&nbsp;Log</a></li>
              <li> <a href='/edit_chapter'><i class="icon-cog"></i>Edit&nbsp;Chapter</a></li>
          % endif
          % if user.is_superuser:
              <li class="nav-header"> System&nbsp;Admin</li>
              <li> <a href='/event_log?type=system'><i class="icon-info-sign"></i>System&nbsp;Log</a></li>
              <li> <a href='/config/chapter_list'><i class="icon-th-list"></i>Chapter&nbsp;List</a></li>
              <li> <a href='/config/events/HS/'><i class="icon-book"></i>Events</a></li>
              <li> <a href='/config/eventsets/'><i class="icon-book"></i>Event&nbsp;Sets</a></li>
          % endif
        </ul>
      </div>
    </div>

    <div id="body" class="span10" align="center">
      <h1>${self.title()}</h1>
      % if messages:
        % for message in messages:
          <div align="center" class="${'error' if str(message).startswith('Error:') else 'info'}">
            ${message}
          </div>
        % endfor
      % endif
      ${next.body()}
    </div>

</div>

<%def name="footer()">
${parent.footer()} &bull; <a href="/contact/">Contact admin</a>
% if not DEPLOYED:
  <div align="center">${len(connection.queries)} SQL queries executed</div>
  <!--<ol>
  % for query in connection.queries:
    <li>${query['sql']}</li>
  % endfor
  </ol>-->
% endif
</%def>

