package amp.ssp

import future.keywords

user[property] := property_val if {
	token := get_token(input.token)

	some prop in ["sub", "name", "uid"]

	property_val := token[prop]
	property := prop
}

permissions contains resource if {
	token := get_token(input.token)

	some resourceName in data.resources

	resource := {
		"resource": resourceName,
		"access": access(resourceName, token)
	}
}

access(resourceName, token) := "deny" if {
	role := token.groups[_]
	data.roles[role][resourceName] == "deny"
} else := "write" {
	role := token.groups[_]
	data.roles[role][resourceName] == "write"
} else := "read" {
	role := token.groups[_]
	data.roles[role][resourceName] == "read"
} else := "deny" {
	true
}

get_token(jwt) = payload if {
	[_, payload, _] := io.jwt.decode(jwt)
}
