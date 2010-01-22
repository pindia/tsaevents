<%inherit file="../base.mako" />
<%
from tsa.events.views import login_url
%>

<%def name="title()">Member Fields</%def>

% if not fields:
    <br>
    No fields defined in the '${category}' category. Create fields on the <a href='/edit_chapter'>Edit Chapter</a> page.
    <% return ''%>
% endif


<p> |
    % for cat in categories:
        % if cat != category:
            <a href="/member_fields/${cat}">${cat}</a>
        % else:
            ${cat}
        % endif
    |
    % endfor
</p>

<form action="/member_fields/${category}" method="post">

<table class="tabular_list" align="center">
    <tr>
      <th>Name</th>
      % for field in fields:
        <th>${field.name}</th>
      % endfor

    </tr>
  % for member in members:
      <tr>
          <td>${member.first_name} ${member.last_name}</td>
          % for field in fields:
            <td>
                % if field.type == 0:
                    <input type="checkbox" ${'checked' if member.profile.get_field(field) else ''} name='${member.id}_${field.id}'>
                % else:
                    <input type="entry" size="12" value="${member.profile.get_field(field)}" name='${member.id}_${field.id}'>
                % endif
            </td>
          % endfor
      </tr>
  % endfor
  </table>

<input type="submit" value="Submit">

</form>

