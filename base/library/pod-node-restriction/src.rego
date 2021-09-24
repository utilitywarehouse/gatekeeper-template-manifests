package podnoderestriction

get_message(node_name) = msg {
  not input.parameters.message
  msg := sprintf("not permitted to be scheduled on node: %s", [node_name])
}

get_message(node_name) = msg {
  msg := input.parameters.message
}

# always match if matchLabels is nil
match_labels(labels) {
  not input.parameters.matchLabels
}

# ensure that every key=value pair in matchLabels is in labels
match_labels(labels) {
  count(input.parameters.matchLabels) == count({label_value | label_value := input.parameters.matchLabels[label_key]; labels[label_key] == label_value})
}

violation[{"msg": msg}] {
  input.review.operation != "DELETE"

  node_name := input.review.object.spec.nodeName
  node := data.inventory.cluster.v1.Node[node_name]

  match_labels(node.metadata.labels)

  msg := get_message(node_name)
}
