<%inherit file="../base.mako"/>

<%def name='title()'>Attendance</%def>

<form action="/attendance" method="post">


<script language="javascript">
$(document).ready(function(){
    $('.view').toggle();
    $('.edit').toggle();
    $('.edit-row').hide();
});
function toggle(id)
{
    $('.edit-row').show();
    $('.view-' + id).toggle();
    $('.edit-' + id).toggle();
    if($('.editcell').not(':hidden').count() == 0)
        $('.edit-row').hide();
}
function confirm_delete_announce()
{
    return confirm('Are you sure you want to delete the announcement?');
}
</script>

    <table class="tabular_list" align="center">
        <tr>
          <th>Name</th>
          <th>Perc</th>
          % for meeting in meetings:
            <th><a href="javascript:toggle(${meeting.id})">${meeting.date.strftime('%b<br>%d')}</a></th>
          % endfor
    
        </tr>
        
      % for member in members:
          <tr>
              <td>${member.first_name} ${member.last_name}</td>
              <td>${member.percent}%</td>
              % for meeting in meetings:
                <td>
                    <div class="view-${meeting.id} view" style="display:none;">
                        % if member in attendees[meeting]:
                            X
                        % else:
                            -
                        % endif
                    </div>
                    <div class="edit-${meeting.id} edit editcell">
                        <input type='checkbox' name='${meeting.id}-${member.id}' ${'checked="yes"' if member in attendees[meeting] else ''}>
                    </div>
                </td>
              % endfor
          </tr>
      % endfor
      
        <tr class="edit-row">
            <th>Delete</th>
            <th>&nbsp;</th>
            % for meeting in meetings:
                <th>
                    <div class="view-${meeting.id} view" style="display:none;">
                        &nbsp;
                    </div>
                    <div class="edit-${meeting.id} edit">
                        <form action="/attendance" method="post">
                        <input type="hidden" name="meeting" value="${meeting.id}">
                        <input type="submit" name="action" value="X">
                        </form>
                    </div>
                </th>
            % endfor
        </tr>

    </table>
    <%
        import datetime
        d = datetime.date.today()
        s = d.strftime('%m/%d/%y')
    %>
    <p>
        <input type='submit' name='action' value='Save'>
    </p>
    <p>
        New meeting:
        <input type='entry' name='date' value='${s}'>
        <input type="submit" name="action" value="Create">
    </p>
</form>

