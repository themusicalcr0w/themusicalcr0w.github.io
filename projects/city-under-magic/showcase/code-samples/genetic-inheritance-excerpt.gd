# Portfolio excerpt from GeneticInheritanceResolver.gd
# Demonstrates ancestry blending, allele selection, linked traits, and mutation.

static func create_child_genome(
	child_body_id: int,
	mother_genome,
	father_genome,
	mutation_rate: float = DEFAULT_MUTATION_RATE
):
	var child := BodyGenomeData.new(child_body_id)
	child.ancestry = _combine_ancestry(mother_genome, father_genome)
	child.lineageMarkers = _inherit_lineage_markers(mother_genome, father_genome)
	child.sourceBodySnapshots = _collect_source_body_snapshots(mother_genome, father_genome)
	var trait_ids := _collect_trait_ids(mother_genome, father_genome)
	for trait_id in trait_ids:
		var child_alleles: Array = []
		var maternal_allele := _inherit_allele(mother_genome, trait_id, "maternal", child_body_id, mutation_rate)
		var paternal_allele := _inherit_allele(father_genome, trait_id, "paternal", child_body_id, mutation_rate)
		if GeneticTraitCatalogData.get_inheritance_mode(trait_id) == GeneticTraitCatalogData.INHERITANCE_LINEAGE_LINKED_Y and not child.lineageMarkers.has("Y"):
			paternal_allele = {}
		if not maternal_allele.is_empty():
			child_alleles.append(maternal_allele)
		if not paternal_allele.is_empty():
			child_alleles.append(paternal_allele)
		child.set_trait_alleles(trait_id, child_alleles)
	child.lineagePhenotype = child.build_lineageEntry_phenotype()
	return child

static func _combine_ancestry(mother_genome, father_genome) -> Dictionary:
	var combined: Dictionary = {}
	for source_genome in [mother_genome, father_genome]:
		if source_genome == null:
			continue
		for ancestry_key in source_genome.ancestry.keys():
			var key := str(ancestry_key)
			combined[key] = float(combined.get(key, 0.0)) + float(source_genome.ancestry[ancestry_key]) * 0.5
	return combined

static func _inherit_allele(source_genome, trait_id: String, lineage_side: String, child_body_id: int, mutation_rate: float) -> Dictionary:
	if source_genome == null:
		return {}
	var source_alleles: Array = source_genome.get_trait_alleles(trait_id)
	if source_alleles.is_empty():
		return {}
	var allele := Dictionary(source_alleles.pick_random()).duplicate(true)
	allele["lineageSide"] = lineage_side
	allele["inheritedFromBodyId"] = source_genome.ownerBodyId
	allele["sourceBodyId"] = int(allele.get("sourceBodyId", source_genome.ownerBodyId))
	allele["inheritanceMode"] = GeneticTraitCatalogData.get_inheritance_mode(trait_id)
	if randf() < clampf(mutation_rate, 0.0, 1.0):
		allele = _mutate_allele(allele, trait_id, child_body_id)
	return allele

static func _mutate_allele(allele: Dictionary, trait_id: String, child_body_id: int) -> Dictionary:
	var mutated := allele.duplicate(true)
	mutated["mutation"] = true
	mutated["mutationTrait"] = trait_id
	mutated["mutationBodyId"] = clampi(child_body_id, 0, 99999)
	mutated["dominance"] = clampf(float(mutated.get("dominance", 0.5)) + randf_range(-0.08, 0.08), 0.0, 1.0)
	mutated["dominanceLabel"] = GeneticTraitCatalogData.get_dominance_label(trait_id, str(mutated.get("id", "")), float(mutated["dominance"]))
	var value = mutated.get("value", null)
	if value is int:
		mutated["value"] = int(value) + randi_range(-3, 3)
	elif value is float:
		mutated["value"] = float(value) + randf_range(-3.0, 3.0)
	elif value is Dictionary:
		var value_dictionary := Dictionary(value).duplicate(true)
		for key in value_dictionary.keys():
			if value_dictionary[key] is int:
				value_dictionary[key] = int(value_dictionary[key]) + randi_range(-3, 3)
			elif value_dictionary[key] is float:
				value_dictionary[key] = float(value_dictionary[key]) + randf_range(-3.0, 3.0)
		mutated["value"] = value_dictionary
	return mutated
