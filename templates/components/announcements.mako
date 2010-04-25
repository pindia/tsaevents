
<%
import datetime
def frmt_datetime(dtime):
    delta = datetime.timedelta( hours=+1 )
    dtime = dtime + delta
    return dtime.strftime("%A, %B %d, %Y - %I:%M %p")
%>


<script language="javascript">
function begin_edit(id)
{
    $('#view-' + id).hide();
    $('#edit-' + id).show()
}
function cancel_edit(id)
{
    $('#view-' + id).show();
    $('#edit-' + id).hide()
}
function confirm_delete_announce()
{
    return confirm('Are you sure you want to delete the announcement?');
}
</script>

<form action='/chapter_info' method='POST'>
  
  <h2>Chapter Announcements</h2>
  
  <table class="datatable" style="width:100%">
      % if (chapter.link or chapter).announcements.count() == 0:
        <tr><td>No chapter announcements.</td></tr>
      % endif
      % for announce in (chapter.link or chapter).announcements.order_by('-create_date'):
          <tr>
              <td id="view-a${announce.id}">
                  % if user.profile.is_admin:
                    [<a href="javascript:begin_edit('a${announce.id}')">Edit</a>]
                  % endif
                  <i>${frmt_datetime(announce.create_date)}</i>: <br>
                  ${announce.render_text()}
              </td>
              <td id="edit-a${announce.id}" style="display:none;">
                  [<a href="javascript:cancel_edit('a${announce.id}')">Cancel</a>]
                  <i>${frmt_datetime(announce.create_date)}</i>: <br>
                  <textarea name="editannounce_${announce.id}" style="width:100%; height:200px">${announce.text}</textarea><br>
                  <!--<input type="checkbox" name="update_date_${announce.id}">Update date-->
                  <input type="submit" value="Save">
                  <input type="submit" name="deleteannounce_${announce.id}" value="Delete" onclick="return confirm_delete_announce()">
              </td>
          </tr>
      % endfor
      <tr>
          <td id="view-acreate">
              % if user.profile.is_admin:
                [<a href="javascript:begin_edit('acreate')">Create new announcement</a>]
              % endif
          </td>
          <td id="edit-acreate" style="display:none;">
              [<a href="javascript:cancel_edit('acreate')">Cancel</a>]
              <textarea name="new_announce" style="width:100%; height:200px;"></textarea><br>
              <input type="submit" value="Create">
          </td>
      </tr>
  </table>
  
  </form>