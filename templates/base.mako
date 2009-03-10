
<html>
  <head>
    <link rel="stylesheet" href="/static/farm/style.css">
    <title>${self.title()}</title>
    <script type="text/javascript" src="/static/farm/jquery.js"></script>
    ${self.scripts()}
    % if msg:
      <!-- <script language="javascript">alert("${msg}");</script> -->
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
          <li> <a href='/'>Your&nbsp;Events</a></li>
          <li> <a href='/event_list'>Event&nbsp;List</a></li>
          <li> <a href='/member_list'>Member&nbsp;List</a></li>
        </ul>
      </td>
      <td align="left" height="20">
        Logged in as ${user} - Events: ${user.events.all().count()} Teams: ${user.teams.all().count()}
      </td>
    </tr>
    <tr class="center"> 
      <td width="100%" valign="top">
          % if msg:
          <p class="red bold">${msg}</p>
          % endif
          ${next.body()}
      </td>
    </tr>
  <table>

  </body>

</html>
<%def name="scripts()"></%def>
<%def name="actions()"></%def>
