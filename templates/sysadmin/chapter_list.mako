<%inherit file='../base.mako' />

<%def name='title()'>Chapter List</%def>

<table class="table table-bordered table-striped" align="center">
    <tr>
        <th>Name</th><th>Level</th><th>State</th><th>Region</th><th>Activate</th>
    </tr>
    % for c in chapters:
    <tr>
        <td>${c.name}</td>
        <td>${c.event_set.level}</td>
        <td>${c.event_set.state}</td>
        <td>${c.event_set.region}</td>
        <td>
            % if chapter == c:
                <a href="?switch_chapter=-1">Deactivate</a>
            % else:
                <a href="?switch_chapter=${c.id}">Activate</a>
            % endif
        </td>
    </tr>
    % endfor
</table>