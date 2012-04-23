<%
def humanize_filesize(s):
    #if s < 1024:
    #    return '%d b' % s
    if s < 1024**2:
        return '%.2f KB' % (s/1024.0)
    if s < 1024**3:
        return '%.2f MB' % (s/1024.0**2)
    else:
        return '%.2f GB' % (s/1024.0**3)

%>

<script language="javascript">

function confirm_delete_file(fname)
{
    return confirm('Are you sure you want to delete "' + fname + '"?');
}

</script>


<form action='/chapter_info' method='POST' enctype='multipart/form-data'>
  
  <h2>Files</h2>
  
  <table class="datatable" style="width:100%">
      % if (chapter.link or chapter).files.count() == 0:
        <tr><td>No chapter files.</td></tr>
      % endif
      % for file in (chapter.link or chapter).files.order_by('-create_date'):
          <tr id="view-f${file.id}">
            % if user.profile.is_admin:
                <td><a href="javascript:begin_edit('f${file.id}')"><i class="icon-edit"></i></a></td>
            % endif     
            <td><a href="${file.file.url}">${file.name}</a></td>
            <td>${humanize_filesize(file.size)}</td>
          </tr>
          <tr id="edit-f${file.id}" style="display:none;">
              <td colspan="10">
                  <a href="javascript:cancel_edit('f${file.id}')"><i class="icon-ban-circle"></i></a>
                  <input type="entry" name="editfile_${file.id}" value="${file.name}">
                  <input type="submit" value="Save" class="btn btn-success btn-small">
                  <input type="submit" name="deletefile_${file.id}" value="Delete" onclick="return confirm_delete_file('${file.name}');" class="btn btn-small btn-danger">
              </td>          
          </tr>
      % endfor
      <tr>
          <td id="view-fcreate" colspan="10">
              % if user.profile.is_admin:
                <a href="javascript:begin_edit('fcreate')"><i class="icon-plus-sign"></i></a>
              % endif
          </td>
          <td id="edit-fcreate" style="display:none;" colspan="10">
              <a href="javascript:cancel_edit('fcreate')"><i class="icon-ban-circle"></i></a>
              <input type="file" name="new_file">
              <input type="submit" value="Upload" class="btn btn-success btn-small">
          </td>
      </tr>
  </table>
  
  </form>