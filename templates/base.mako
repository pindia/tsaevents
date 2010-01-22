<html>
  <head>
    <link rel="stylesheet" href="/static/tsa/style.css">
    <title>${self.title()}</title>
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js"></script>
    ${self.scripts()}
    % if not DEPLOYED:
      <style>body {background-color: green;}</style>
    % endif
  </head>
    <body>
  <table width="100%" class="layout">
    <tr class="center"><td class="header" colspan="2">
      TSA Event Registration - ${self.title()}
    </td></tr>
    <tr>
      <td valign="top" rowspan="3">
        <p class="name">Navigation</p>
        <ul class="text">
          % if user.profile.chapter:
            <li> <a href='/'>Your&nbsp;Events</a></li>
            <li> <a href='/event_list'>Event&nbsp;List</a></li>
            <li> <a href='/member_list'>Member&nbsp;List</a></li>
            <li> <a href='/team_list'>Team&nbsp;List</a></li>
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
      </td>
      <td align="left" height="20">
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
        % if user.profile.chapter.name.startswith('State High') and user.is_superuser:
          [<a href="?STATEHIGH_SWITCH">Switch</a>]
        % endif
        |
        Events: ${user.events.all().count()} Teams: ${user.teams.all().count()}
        |
        <a href="/settings">Settings</a>
        <a href="/accounts/logout">Logout</a>
      </td>
    </tr>
    <tr class="center"> 
      <td width="100%" valign="top">
          % if messages:
            % for message in messages:
              <div class="${'error' if message.startswith('Error:') else 'info'}">${message}</div>
            % endfor
          % endif
          ${next.body()}
      </td>
    </tr>
  <table>
  % if not DEPLOYED:
    <div align="center">${len(connection.queries)} SQL queries executed</div>
    <!--<ol>
    % for query in connection.queries:
      <li>${query['sql']}</li>
    % endfor
    </ol>-->
  % endif
  </body>

</html>
<%def name="scripts()"></%def>
<%def name="actions()"></%def>
