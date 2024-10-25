cache_names=("multilingual_prompting_method") #此处输入你的【论文主题】文件夹, 【论文主题】咋在第7行的topic_description

1. Related Paper Search
python3 src/lit_review.py \
 --engine "claude-3-5-sonnet-20240620" \
 --mode "topic" \
 --topic_description "novel prompting methods to improve large language models’ performance on multilingual tasks or low-resource languages and vernacular languages" \
 --cache_name "../cache_results_test/lit_review/multilingual_prompting_method.json" \
 --max_paper_bank_size 50 \
 --print_all


# 2. Grounded Idea Generation
cache_names=("multilingual_prompting_method")
ideas_n=5 ## batch size
methods=("prompting")
rag_values=("True" "False")

for seed in {1..2}; do
    # Iterate over each topic name 
    for topic in "${cache_names[@]}"; do
        # Iterate over each method 
        for method in "${methods[@]}"; do
            # Iterate over RAG values True and False
            for rag in "${rag_values[@]}"; do
                echo "Running grounded_idea_gen.py on: $topic with seed $seed and RAG=$rag"
                python3 src/grounded_idea_gen.py \
                 --engine "claude-3-5-sonnet-20240620" \
                 --paper_cache "../cache_results_test/lit_review/$topic.json" \
                 --idea_cache "../cache_results_test/seed_ideas/$topic.json" \
                 --grounding_k 10 \
                 --method "$method" \
                 --ideas_n $ideas_n \
                 --seed $seed \
                 --RAG $rag 
            done
        done
    done
done



# 3. Idea Deduplication
cache_dir="../cache_results_test/seed_ideas/"

for cache_name in "${cache_names[@]}"; do
    echo "Running analyze_ideas_semantic_similarity.py with cache_name: $cache_name"
    python3 src/analyze_ideas_semantic_similarity.py \
    --cache_dir "$cache_dir" \
    --cache_name "$cache_name" \
    --save_similarity_matrix 
done

for cache_name in "${cache_names[@]}"; do
    echo "Running dedup_ideas.py with cache_name: $cache_name"
    python3 src/dedup_ideas.py \
    --cache_dir "$cache_dir" \
    --cache_name "$cache_name" \
    --dedup_cache_dir "../cache_results_test/ideas_dedup" \
    --similarity_threshold 0.8 
done




# 4. Project Proposal Generation
idea_cache_dir="../cache_results_test/ideas_dedup/"
project_proposal_cache_dir="../cache_results_test/project_proposals/"
seed=2024

for cache_name in "${cache_names[@]}"; do
    echo "Running experiment_plan_gen.py with cache_name: $cache_name"
    python3 src/experiment_plan_gen.py \
    --engine "claude-3-5-sonnet-20240620" \
    --idea_cache_dir "$idea_cache_dir" \
    --cache_name "$cache_name" \
    --experiment_plan_cache_dir "$project_proposal_cache_dir" \
    --idea_name "all" \
    --seed $seed \
    --method "prompting" 
done




# project proposal ranking
# skipped here to save costs
experiment_plan_cache_dir="../cache_results_test/project_proposals/"
ranking_score_dir="../cache_results_test/ranking/"
seed=2024

for cache_name in "${cache_names[@]}"; do
    echo "Running tournament_ranking.py with cache_name: $cache_name"
    python3 src/tournament_ranking.py \
    --engine claude-3-5-sonnet-20240620 \
    --experiment_plan_cache_dir "$experiment_plan_cache_dir" \
    --cache_name "$cache_name" \
    --ranking_score_dir "$ranking_score_dir" \
    --max_round 5 
done



# # Project Proposal Filtering (Optional)
# # skipped here to save costs
# cache_dir="../cache_results_test/project_proposals/"
# passed_cache_dir="../cache_results_test/project_proposals_passed/"
# seed=2024

# # Iterate over each cache name and run the Python script
# for cache_name in "${cache_names[@]}"; do
#     echo "Running filter_ideas.py with cache_name: $cache_name"
#     python3 src/filter_ideas.py \
#     --engine "claude-3-5-sonnet-20240620" \
#     --cache_dir "$cache_dir" \
#     --cache_name "$cache_name" \
#     --passed_cache_dir "$passed_cache_dir" \
#     --score_file "../cache_results_test/ranking/$cache_name/round_5.json" 
# done
