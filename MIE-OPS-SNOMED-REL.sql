#conncet to your OMOP database, check valid schema in your DB ohdsi to conncet to
#the script will return the needed data, to analysis in the corresponding python script, also provided by this repository
WITH 
    OPS AS 
    (   SELECT 
            C.concept_id AS concept_id
        FROM 
            concept C
        WHERE 
            C.vocabulary_id = 'OPS'
    ) 
    ,
    OPS_REL AS 
    (   SELECT 
            DISTINCT concept_id_1
        FROM 
            concept_relationship S
        JOIN 
            OPS 
        ON 
            OPS.concept_id = S.concept_id_1
        WHERE 
            S.relationship_id !='Maps to' 
    ) 
    ,
    CODES AS
    (   SELECT
            *
        FROM
            concept CON
        JOIN
            concept_relationship REL
        ON
            REL.concept_id_1 = CON.concept_id
        WHERE
            REL.relationship_id = 'Maps to'
        AND CON.vocabulary_id = 'OPS'
    )
    ,
    COUNTCODE AS
    (   SELECT
            COUNT(concept_id) AS numMaps,
            concept_id,
            concept_code
        FROM
            CODES
        GROUP BY
            concept_id, 
            concept_code
    )
SELECT 
    procedure_source_concept_id, 
    COUNT(procedure_source_concept_id), 
    concept.concept_code, 
    numMaps 
FROM 
    procedure_occurrence
JOIN 
    concept 
ON 
    concept_id=procedure_source_concept_id
JOIN 
    concept_synonym 
ON 
    procedure_source_concept_id=concept_synonym.concept_id
LEFT JOIN 
    COUNTCODE 
ON 
    procedure_source_concept_id=COUNTCODE.concept_id
WHERE 
    concept.vocabulary_id = 'OPS'
GROUP BY 
    procedure_source_concept_id, 
    concept.concept_code, 
    numMaps
   ; 