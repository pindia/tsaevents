<%inherit file="base.mako" />

<%def name="title()">Member List</%def>

<%def name="scripts()">
    <script language="javascript">
    function confirmSubmit()
    {
        var a = $('#action_select option:selected').attr('value')
        if(a=='delete')
            return confirm('Warning: deleting users will IRREVERSIBLY DESTROY all data relating to them, including entries, teams, and team posts. Are you sure you want to delete the selected users?');
        if(a=='promote')
            return confirm('Warning: officers have FULL CONTROL over the entire chapter, including the ability to delete users, teams, and event entries. Are you sure you want to promote the selected users to officers?');
        if(a=='demote')
            return confirm('Normal members are able to sign up for events, but have no administrative powers. Are you sure you want to change the selected users to normal members?');
        if(a=='advisor')
            return confirm('Warning: advisor accounts have FULL CONTROL over the entire chapter like officers, but cannot sign up for events. Are you sure you want to change the selected users to advisors?');
        if(a=='none')
            return true;
        return false;
    }
    
    function confirmRemove(ename, uname, target)
    {
      var ok = confirm('Are you sure you want to remove "' + ename +'" from ' + uname + '\'s events?');
      if(ok)
        location.href=target;
      return false;
    }
    
    </script>
</%def>



<%def name="render_indi_event(event, member)" buffered="True">
    ${event.short_name.replace(' ','&nbsp;')}
    % if user.profile.is_admin:
      <a href="javascript:void(0)" onclick="confirmRemove('${event.name}', '${member.first_name} ${member.last_name}', '?action=remove_event&uid=${member.id}&eid=${event.id}');"><img src="/static/tsa/icons/delete.png" border="0"></a>
    % endif
</%def>

<%def name="render_team_event(team)" buffered="True">
    <a href="/teams/${team.id}">${team.event.short_name.replace(' ','&nbsp;')}</a>
</%def>

% if user.profile.is_admin:
<p>See the <a href="/help/advisor_guide#user-management">advisor guide</a> for details about using this page.</p>
% endif

    <form action="/member_list/" method="get">
    Filter by Event:
    <select name="event">
        <option value="">-----All-----</option>
        % for event in events.filter(is_team=False):
            <option value="${event.id}" ${'selected="yes"' if str(event.id) == selected_event else ''}>${event.name}</option>
        % endfor
    </select>
    <input type="submit" value="Filter">
    </form>

<form action="?" method="post">

<table class="datatable" align="center">
    <tr>
      % if user.profile.is_admin:
        <th>&nbsp;</th>
      % endif
      <th width="120">Name</th>
      % if MODE != 'nation':
        <th>TSA ID</th>
      % endif
      <th>#E</th>
      <th>Individual</th>
      <th>Team</th>
    </tr>
  % for member in members:
      <tr class="${cycle.next()}">
          % if user.profile.is_admin:
            <td><input type="checkbox" name="edit_${member.id}"></td>
          % endif
          <td>
          % if member.profile.is_admin:
            <i>${member.first_name} ${member.last_name}</i>
          % else:
            ${member.first_name} ${member.last_name}
          % endif  
            
        </td>
          % if not member.profile.is_member:
          <td colspan="5">Advisor</td>
          % else:
            % if MODE != 'nation':
              <td style="white-space: nowrap;">
                % if user.profile.is_admin:
                    ${chapter.chapter_id}-<input type="entry" name="id_${member.id}" value="${member.profile.get_id()}" size="1">
                % else:
                    ${'%s-%s' % (chapter.chapter_id, member.profile.get_id()) if member.profile.indi_id else '-'}
                % endif
              </td>
            % endif
            <td>${member.events.count() + member.teams.count()}</td>
            <td>
                  ${'&bull;'.join([render_indi_event(event, member) for event in member.events.all()]) or '&nbsp;'}
            </td>
            <td>
                  ${'&bull;'.join([render_team_event(team) for team in member.teams.all()]) or '&nbsp;'}
            </td>
          % endif
      </tr>
  % endfor
  % if not members:
      <tr><td colspan="99">No members matching filters found. <a href="/member_list">View all</a><td></tr>
  % endif
  </table>



% if user.profile.is_admin and members:

    <table class="aligner">

    <tr>
        <td>Add event/Create team:</td>
        <td>
            <select name="eid">
                <option value="-1"> --- Select event ---</option>
                <optgroup label="Add events to all selected:">
                    % for e in events.filter(is_team=False):
                        <option value="${e.id}">${e.name}</option>
                    % endfor
                </optgroup>
                <optgroup label="Create team of those selected:">
                    % for e in events.filter(is_team=True):
                        <option value="${e.id}">${e.name}</option>
                    % endfor
                </optgroup>
            </select>
        </td>
    </tr>
    
    <tr>
        <td>Administer Users:</td>
        <td>
            <select name="action" id="action_select">
                <option value="none"> --- Select action --- </option>
                <option value="delete">Delete selected users</option>
                <option value="promote">Change selected users to officers</option>
                <option value="demote">Change selected users to normal members</option>
                <option value="advisor">Change selected users to advisors</option>
            </select>
        </td>
    </tr>
    <tr>
        <td colspan="2" style="text-align: center;"><input type="submit" value="Update Users" onclick="return confirmSubmit(); "></td></td>
    
    </table>
% endif

</form>

<p>Printable views: <a href="/member_list/?checklist">Checklist</a>

