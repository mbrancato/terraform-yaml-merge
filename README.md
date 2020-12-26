# terraform-yaml-merge-lists

This module can be used to merge two YAML files. The goal was to allow merging
of certain configurations without the need of an external program such as `yq`
to do the merging. The initial use-case for building this was to take a "base" 
cloud-init and allow adding additional config when constructing VM instances.

## Compatibility

There are multiple strategies for merging YAML data. The approach here is to
combine lists of strings in the top-level keys of the data, if the keys exist
in both sets of YAML data being merged. Supported types for merging include
only those that may be converted to a string including internal Terraform types
of string, number and bool. For keys unique to both sets of data, their data is
included in the result as the original type. If there is a conflict for a
supported non-list type, it will be returned as a list of strings in the
result. Anything consuming the result must understand that certain types, such
as numbers, are going to be returned as a list of strings.

For example, if the first set has `name: foo` and the second set has
`name: bar`, the result would be:

```
name:
- foo
- bar
```
