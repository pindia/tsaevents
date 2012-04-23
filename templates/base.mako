<%inherit file="layout.mako" />


<%def name="header()">
    <div class="hidden-phone">
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
    </div>
    <div class="visible-phone">
        ${user.first_name} ${user.last_name} &bull;
        ${user.profile.chapter}
            % if user.profile.chapter and (user.profile.chapter.link or user.profile.chapter.reverselink) and user.profile.is_admin:
                    [<a href="?SWITCH_CHAPTER">Switch</a>]
            % endif
    </div>
</%def>

<div class="row">

    <div id="navigation-container" class="span2">

      <div id="navigation" class="datatable">

          <a class="btn btn-mini btn-inverse btn-navbar" style="float: right; margin-right: 2px; margin-top: 2px; padding: 2px 6px;" data-toggle="collapse" data-target=".nav-collapse">
              show
          </a>

          <ul class="nav nav-list">
          <li class="nav-header">Navigation</li>
          </ul>



          <div class="nav-collapse">



          <ul class="nav nav-list">

                % if user.profile.chapter:
                <li> <a href='/'><i class="icon-home"></i>Home</a></li>
                <li> <a href='/event_list'><i class="icon-book"></i>Events</a></li>
                <li> <a href='/member_list/'><i class="icon-user"></i>Members</a></li>
                <li> <a href='/team_list/'><i class="icon-th-list"></i>Teams</a></li>
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
                  <li> <a href='/event_log?type=all'><i class="icon-info-sign"></i>System&nbsp;Log</a></li>
                  <li> <a href='/config/chapter_list'><i class="icon-th-list"></i>Chapter&nbsp;List</a></li>
                  <li> <a href='/config/events/HS/'><i class="icon-book"></i>Events</a></li>
                  <li> <a href='/config/eventsets/'><i class="icon-book"></i>Event&nbsp;Sets</a></li>
              % endif

              <li class="nav-header">Account</li>
              <li><a href="/settings"><i class="icon-cog"></i>Settings</a></li>
              <li><a href="/accounts/logout"><i class="icon-off"></i>Logout</a></li>

            </ul>
          </div>

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
${parent.footer()} &bull; <a href="/contact/">Contact </a> &bull; <a href="/help/">Help</a>
% if not DEPLOYED:
  <div align="center">${len(connection.queries)} SQL queries executed</div>
  <!--<ol>
  % for query in connection.queries:
    <li>${query['sql']}</li>
  % endfor
  </ol>-->
% endif
</%def>

