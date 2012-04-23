<%inherit file='base.mako' />

<%def name='title()'>Event Log </%def> <% %>

<%
import datetime
def frmt_datetime(dtime):
    delta = datetime.timedelta( hours=+1 )
    dtime = dtime + delta
    return dtime.strftime("%a, %b %d %I:%M %p")
    
ICONS = {
'event_add':'script_add.png',
'event_remove':'script_delete.png',
'team_create':'group_add.png',
'team_join':'script_add.png',
'team_remove':'script_delete.png',
'team_leave':'script_delete.png',
'team_promote':'group_gear.png',
'team_delete':'group_delete.png',
'edit_team_ids':'group_edit.png',
'team_post':'comment_add.png',
'team_post_delete':'comment_delete.png',
'admin_lock':'lock_edit.png',
'password_change':'key.png',
'new_user':'user_add.png',
'user_edit':'user_edit.png',
'user_delete':'user_delete.png',
}
    

%>

<p>
|
<a href="?type=personal">Affecting me</a>|
<a href="?type=actions">My actions</a>|
% if user.profile.is_admin:
<a href="?type=chapter">Chapter log</a>|
% endif
% if user.is_superuser:
<a href="?type=system">System log</a>|
<a href="?type=all">Global log</a>|
% endif


</p>



<table class="table table-striped table-condensed" align="center">
    <tr>
        <th>&nbsp;</th>
        <th>Date</th>
        <th>Text</th>
    </tr>
    % for log in logs:
    <tr class="${cycle.next()}">
        <td>
        % if log.type in ICONS:
            <img src="/static/tsa/icons/${ICONS[log.type]}">
        % else:
            &nbsp;
        % endif
        </td>
        <td>${frmt_datetime(log.date)}</td>
        <td>${log.text}</td>
    </tr>
    % endfor
</table>