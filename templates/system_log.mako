<%inherit file='base.mako' />

<%def name='title()'>System Log </%def> <% %>

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
'team_join':'group.png',
'team_remove':'group_go.png',
'team_leave':'group_go.png',
'team_promote':'group_gear.png',
'team_delete':'group_delete.png',
'team_post':'comment_add.png',
'team_post_delete':'comment_delete.png',
'admin_lock':'lock_edit.png',
'password_change':'key.png',
'new_user':'user_add.png'
}
    

%>

<table class="tabular_list" align="center">
    <tr>
        <th>&nbsp;</th>
        <th>Date</th>
        <th>Text</th>
    </tr>
    % for log in logs:
    <tr>
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