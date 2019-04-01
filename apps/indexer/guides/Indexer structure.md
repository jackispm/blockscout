fetch/pending_transactions.ex

fetch/blocks.ex
fetch/transactions.ex
fetch/blocks/realtime.ex
fetch/blocks/catchup.ex
fetch/blocks/uncles.ex

fetch/block_rewards.ex
fetch/internal_transactions.ex
fetch/tokens.ex
fetch/token_balances.ex
fetch/contract_codes.ex

fetch/replaced_transactions.ex (???)

fetch/coin_balances.ex (???)


transform/blocks.ex
transform/addresses.ex
transform/address_coin_balances.ex
transform/address_token_balances.ex
transform/mint_transfers.ex
transform/token_transfers.ex





































# Workers

## Uncataloged token transfers

Files:
	token_transfer/uncataloged/supervisor.ex
	token_transfer/uncataloged/worker.ex

Finds all logs with certain first_topic, where:
1. transaction belongs to a block
2. no TokenTransfer is recorded

Gets a list of blocks and "forces" to refetch them.
!!! Can be replaced by SQL query to mark blocks as non-consensus.


## Replaced transactions

Files:
	replaced_transaction/fetcher.ex
	replaced_transaction/supervisor.ex

Marks transactions not belonging to any block as `dropped/replaced` if there's a transaction with the same address/nonce in any block.
1. On launch fetches all pending transactions and marks those with corresponding collated transactions
2. Asynchronous call from block fetcher with collated transactions marks corresponding pending transactions

Async fetch: `async_fetch [%{block_hash, from_address_hash, nonce}]`

Settings:
	flush_interval: :timer.seconds(3)
	max_batch_size: 10
	max_concurrency: 4

!!! Disabled due to bad performance






# On-demand Fetchers








# Extractors

## Token, TokenTransfer

Files:
	token_transfer/parser.ex
	token_transfers.ex

From:
	logs (raw)

Extracted data:
	token:
		contract_address_hash: log.address_hash,
		type (ERC-20 / ERC-721)
	
	token transfer:
		amount (ERC-20)
		token_id (ERC-721)

		block_number
		transaction_hash
		log_index

		from_address_hash
		to_address_hash
		token_contract_address_hash
		token_type

Left null:
	token:
		cataloged
		name
		symbol
		total_supply
		decimals
		holder_count

## CoinBalance

Files:
	address/coin_balances.ex

From:
	beneficiary_params
	blocks_params
	internal_transactions_params (???)
	logs_params
	transactions_params
	block_second_degree_relations_params (???)

Extracted data:
	address_hash
	block_number

Left null:
	value
	value_fetched_at

!!! Investigate, why internal transactions and 2nd degree blocks are not processed

## TokenBalance

Files:
	address/token_balances.ex

From:
	token_transfers_params

Extracted data:
	address_hash
	token_contract_address_hash
	block_number

Left null:
	value
	value_fetched_at

!!! Fix idiotic burn address filtering both here and in query
!!! Delete burn address balances from database

## Address

Files:
	address_extraction.ex

From:
	address_coin_balances
	blocks
	internal_transactions
	codes
	transactions
	logs
	token_transfers
	mint_transfers

Extracted data:
	hash
	contract_code
	fetched_coin_balance
	fetched_coin_balance_block_number
	nonce

Left null:
	fetched_coin_balance (sometimes)

## MintTransfer

Files:
	mint_transfer.ex

From:
	logs (raw)

Extracted data:
	block_number
	from_address_hash
	to_address_hash

Only used for extracting Address from it

## Block miner hash

Files:
	block/transform.ex
	block/transform/base.ex
	block/transform/clique.ex
	block/util.ex

From:
	blocks (raw)

Extracted data:
	miner_hash

Miner hash from additional data for Clique chains


# Infrastructure














block/supervisor.ex




















memory/monitor.ex
memory/shrinkable.ex
shrinkable/supervisor.ex


application.ex
bound_interval.ex
bound_queue.ex
buffered_task.ex
logger.ex
sequence.ex
tracer.ex
worker.ex













