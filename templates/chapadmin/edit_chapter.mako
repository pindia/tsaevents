<%inherit file='../base.mako' />

<%def name='title()'>Home</%def> <%%>

<h2>Chapter Information</h2>

<table align="center">
    <tr><td>Name:</td><td>${chapter.name}</td></tr>
    % if chapter.link:
        <tr><td><i>Master:</i></td><td><i>${chapter.link.name}</i></td>
    % endif
    <tr><td>Members:</td><td>${chapter.members.count()}</td></tr>
    <tr><td>Teams:</td><td>${chapter.teams.count()}</td></tr>
</table>

<form method="post" action="/edit_chapter">

<h2>Fields</h2>
<table align="center" class="tabular_list">
    <tr><th>Name</th><th>Category</th><th>Weight</th><th>Type</th><th>Default</th></tr>
    % for field in chapter.get_fields():
    <tr>
        <td><input type="entry" size="6" name="${field.id}_name" value="${field.name}"></td>
        <td><input type="entry" size="6" name="${field.id}_category" value="${field.category}"></td>
        <td><input type="entry" size="6" name="${field.id}_weight" value="${field.weight}"></td>
        <td>${field.get_type_display()}</td>
        <td>${field.format_value(field.default_value)}</td>
    </tr>
    % endfor
</table>
<h4>New Field</h4>
% if chapter.link:
    Switch to master chapter to edit field
% else:

        Name: <input type="entry" name="name"><br>
        Type: <input type="entry" name="type"><br>
        Default: <input type="entry" name="default"><br>
        <input type="submit" value="Submit">
% endif

    </form>