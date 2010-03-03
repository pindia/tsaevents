<%inherit file='../base.mako' />

<%def name='title()'>Edit Chapter</%def>
<%
def sel(cond):
    return 'selected="yes"' if cond else ''

%>

<h2>Chapter Information</h2>

<table align="center">
    <tr><td>Name:</td><td>${chapter.name}</td></tr>
    % if chapter.link:
        <tr><td><i>Master:</i></td><td><i>${chapter.link.name}</i></td>
    % endif
    <tr><td>Members:</td><td>${chapter.members.filter(is_member=True).count()}</td></tr>
    <tr><td>Teams:</td><td>${chapter.teams.count()}</td></tr>
</table>

<form method="post" action="/edit_chapter">

<h2>Fields</h2>
<table align="center" class="tabular_list">
    <tr>
        <th>Name</th>
        <th>Short Name</th>
        <th>Category</th>
        <th>Weight</th>
        <th>Who may view?</th>
        <th>Who may edit?</th>
        <th>Type</th>
        <th>Default</th>
    </tr>
    % for field in chapter.get_fields():
    <tr>
        <td><input type="entry" size="15" name="${field.id}_name" value="${field.name}"></td>
        <td><input type="entry" size="6" name="${field.id}_short_name" value="${field.short_name}"></td>
        <td><input type="entry" size="6" name="${field.id}_category" value="${field.category}"></td>
        <td><input type="entry" size="2" name="${field.id}_weight" value="${field.weight}"></td>
        
        <td>
            <select name="${field.id}_view_perm">
                <option value="0" ${sel(field.view_perm == 0)}>Admin only</option>
                <option value="1" ${sel(field.view_perm == 1)}>Admin or user</option>
            </select>
        </td>
        <td>
            <select name="${field.id}_edit_perm">
                <option value="3" disabled ${sel(field.edit_perm == 3)}>Editing locked</option>
                <option value="2" disabled ${sel(field.edit_perm == 2)}>Admin only (logged)</option>
                <option value="0" ${sel(field.edit_perm == 0)}>Admin only</option>
                <option value="1" disabled ${sel(field.edit_perm == 1)}>Admin or user</option>
            </select>
        </td>
        
        <td>${field.get_type_display()}</td>
        <td>${field.format_value(field.default_value)}</td>
    </tr>
    % endfor
</table>
% if chapter.link:
    Switch to master chapter to edit field
% else:
<h3>New Field</h3>
    <table class="layouttable aligner">
        <tr><td>Name:</td><td><input type="entry" name="name"></td></tr>
        <tr><td>Short Name:</td><td><input type="entry" name="short_name"></td></tr>
        <tr><td>Type:</td><td>
        <select name="type">
            <option value="text">Text</option>
            <option value="boolean">Boolean (Yes/No)</option>
        </select></td></tr>
        <tr><td>Default:</td><td><input type="entry" name="default"></td>
    </table>
% endif
        <input type="submit" value="Submit">
    </form>