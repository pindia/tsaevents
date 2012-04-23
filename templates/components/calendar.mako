<%
import datetime
def frmt_date(dtime):
    #delta = datetime.timedelta( hours=+1 )
    #dtime = dtime + delta
    return dtime.strftime("%a, %b %d")

def days_until(date):
    today = datetime.date.today()
    if date == today:
        return '(Today)'
    else:
        delta = date - today
        return '(%d days)' % (delta.days)


%>

<script language="javascript">

function confirm_delete_event(ename)
{
    return confirm('Are you sure you want to delete "' + ename + '"?');
}

</script>

<%def name="edit_form(event=None)">
    <%
    if not event:
        name = 'Event Name'
        d = datetime.date.today()
        id = 'create'
    else:
        name = event.name
        d = event.date
        id = event.id
    months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
    %>
    
    <input type="entry" name="editeventname_${id}" value="${name}"><br>
    <select name="editeventmonth_${id}">
    % for month in range(1, 13):
        <option value="${month}" ${"selected='yes'" if d.month == month else ""}>${months[month-1]}</option>
    % endfor
    </select>
    <select name="editeventday_${id}">
    % for day in range(1, 32):
        <option value="${day}" ${"selected='yes'" if d.day == day else ""}>${"%02d" % (day)}</option>
    % endfor
    </select>
    <select name="editeventyear_${id}">
    % for year in range(2010, 2020):
        <option value="${year}" ${"selected='yes'" if d.year == year else ""}>${year}</option>
    % endfor
    </select>


</%def>


<form action='/chapter_info' method='POST' enctype='multipart/form-data'>
  
  <h2>Calendar</h2>
  
  <table class="datatable" style="width:100%">
    <%
        calendar = (chapter.link or chapter).calendar_events.filter(date__gte=datetime.date.today()).order_by('date')
    %>
      % if calendar.count() == 0:
        <tr><td>No chapter events.</td></tr>
      % endif
      % for event in calendar:
          <tr id="view-e${event.id}">
            % if user.profile.is_admin:
                <td><a href="javascript:begin_edit('e${event.id}')"><i class="icon-edit"></i></a></td>
            % endif     
            <td>${event.name}</td>
            <td style="white-space:nowrap;">${frmt_date(event.date)}</td>
            <td style="white-space:nowrap;">${days_until(event.date)}</td>
          </tr>
          % if user.profile.is_admin:
            <tr id="edit-e${event.id}" style="display:none;">
                <td colspan="10">
                    <a href="javascript:cancel_edit('e${event.id}')"><i class="icon-ban-circle"></i></a>
                    ${edit_form(event)}
                    <input type="submit" value="Save" class="btn btn-success btn-small">
                    <input type="submit" name="deleteevent_${event.id}" value="Delete" onclick="return confirm_delete_event('${event.name}');" class="btn btn-danger btn-small">
                </td>          
            </tr>
          % endif
      % endfor
      <tr>
          <td id="view-ecreate" colspan="10">
              % if user.profile.is_admin:
                <a href="javascript:begin_edit('ecreate')"><i class="icon-plus-sign"></i></a>
              % endif
          <div style="float: right"><a href="/calendar.ics?chapter=${chapter.id}&key=${chapter.calendar_key}"><img src="/static/tsa/icons/ical.gif"></a></div>
          </td>
          % if user.profile.is_admin:
            <td id="edit-ecreate" style="display:none;" colspan="10">
                <a href="javascript:cancel_edit('ecreate')"><i class="icon-ban-circle"></i></a>
                ${edit_form()}
                <input type="submit" value="Create" name="create_event">
            </td>
          % endif
      </tr>
  </table>
  
  
  </form>