package namelabelmatch

violation[{"msg": msg, "details": {
    "label_name": label_name,
    "metadata_name": metadata_name,
}}] {
    metadata_name := input.review.object.metadata.name
    label_name := input.review.object.metadata.labels.name

    label_name != metadata_name

    msg := sprintf("the label 'name' (%v) must match the actual name of the object (%v)", [label_name, metadata_name])
}
