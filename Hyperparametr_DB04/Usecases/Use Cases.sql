-- 1) What is the maximum accuracy from all the generated models?
SELECT leader_board_modelId, auc 
FROM hp04.classification_metrics
ORDER BY auc DESC
LIMIT 1;

-- 2) What is the run time for best AUC score which has hyperparameters?
SELECT leader_board_modelId, r.run_time
FROM classification_metrics c
JOIN leader_board l ON l.modelId = c.leader_board_modelId
JOIN run_time r ON r.runID = l.run_time_runId
WHERE auc = (SELECT MAX(auc)
			FROM classification_metrics);

-- Q3) Which model ID gives the best log loss value? (To check whether Best AUC and logloss belong to the same model?)
SELECT leader_board_modelId, logloss
FROM classification_metrics
ORDER BY 2
LIMIT 1;

-- Q4) What are the columns and its datatypes for the used dataset (given to H2O)?
SELECT column_name, column_datatype
FROM column_type
WHERE dataset_dataset_id = 1;

-- Q5) What is the best algorithm for classification/regression type?
SELECT LEFT(leader_board_modelId,3) AS Algo_Name
FROM classification_metrics c
JOIN leader_board l ON l.modelId = c.leader_board_modelId
WHERE auc = (SELECT MAX(auc)
			FROM classification_metrics);
            
            
-- Q6) What is the min and max values of given hyperparameters?
call hp_min_max_proc('learn_rate');

call hp_range();

-- Q7) Common hypermeters from different algorithms
SELECT a.HP04,b.algorithm_name FROM hp04.default_values as a,hp04.algorithm as b
WHERE a.algorithm_algo_id = b.algo_id
GROUP BY a.HP04
HAVING COUNT(a.HP04) > 1;


-- Q8) What are the important parameters for a particular model?
SELECT a.HP04,b.algorithm_name from hp04.default_values as a,
hp04.algorithm as b where importance = 'Y' AND a.algorithm_algo_id = b.algo_id;



-- Q9) BEST model based on sum of rmse and mse score
SELECT leader_board_modelId, (rmse+mse) as Total_Error
FROM hp04.classification_metrics
ORDER BY 2
LIMIT 1;

-- Q10) default values for common hyperparameters across different algorithms
SELECT a.HP04,b.algorithm_name,a.hyper_def_values FROM hp04.default_values as a,hp04.algorithm as b
WHERE a.algorithm_algo_id = b.algo_id
GROUP BY a.HP04
HAVING COUNT(a.HP04) > 1;



-- VIEWS



-- 1) List of all datasets used 

CREATE VIEW `hp04`.`list_of_datasets` AS 
select `hp04`.`dataset`.`dataset_id` AS `dataset_id`,`hp04`.`dataset`.`dataset_name` AS 
`dataset_name`,`hp04`.`dataset`.`domain_name` AS `domain_name`,`hp04`.`dataset`.`problem_type` 
AS `problem_type` from `hp04`.`dataset`;

SELECT * FROM hp04.list_of_datasets;


-- 2) List of all runtimes and respective models for those runtimes

CREATE VIEW `hp04`.`model_runtime` AS 
SELECT a.modelId,b.run_time FROM leader_board AS a,run_time AS b WHERE a.run_time_runId = b.runId;

SELECT * FROM hp04.model_runtime;



-- 3)All hyperparameters and default values

CREATE VIEW `hp04`.`default_hp_val` AS 
select a.HP04 AS HP04,a.hyper_def_values AS hyper_def_values,b.algorithm_name AS algorithm_name 
from (hp04.default_values a join hp04.algorithm b on((a.algorithm_algo_id = b.algo_id)));

SELECT * FROM hp04.default_hp_val;



-- 4)All models with no hyperparameters
CREATE VIEW `hp04`.`model_with_no_hyperparameter` 
AS select hp04.classification_metrics.auc AS auc,hp04.classification_metrics.logloss AS 
logloss,hp04.classification_metrics.mean_per_class_error 
AS mean_per_class_error,hp04.classification_metrics.rmse 
AS rmse,hp04.classification_metrics.mse 
AS mse,hp04.classification_metrics.class_id 
AS class_id,hp04.classification_metrics.leader_board_modelId AS leader_board_modelId 
from hp04.classification_metrics where (hp04.classification_metrics.leader_board_modelId like 'Stack%');


SELECT * FROM hp04.model_with_no_hyperparameter;

-- FUNCTIONS

-- 1) Best model for the given domain with its hyperparameters.
call hp04.Best_for_domain('Human Resources');

-- 2)What are the minimum and maximum values of given hyperparameter.
call hp04.hp_min_max_proc('learn_rate');


-- 3)Count of all models under given algorithm and runtime.
select hp04.Avg_no_of_models1('GBM', 700);

-- 4)What are the actual,default values and the range of learn_rate hyperparameter
call hp04.hp_range();


