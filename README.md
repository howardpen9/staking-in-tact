# Example of Jetton Token Staking

```bash
yarn test # To test contract
yarn build # To build contract
yarn deploy # To deploy contract
yarn d1 # To run 1_Transfer_Stake, that transfers stake from one jetton wallet to the staking contract
yarn d2 # Generate the link to run 2_Stake, that enable for user to stakes jettons(based on the walletV4 contract address you gave to)
```

## Deployment

To deploy contract you should:

1. Specify `contract.tact` that will be used as entry point of your contract
2. Configure `contract.deploy.ts` according to your `contract.tact` to generate a deployment link. In particular, it is necessary to correctly call the Init() function from the contract.

If you renamed `contract.tact` to something else, you need to update `tact.config.json` correspondingly. For more information , see [Tact Documentation](https://docs.tact-lang.org/language/guides/config)

## Testing

Example of contract tests are in `contract.spec.ts`. For more information about testing, see [Tact Documentation](https://docs.tact-lang.org/language/guides/debug)

To add new test files to contract you should create `*.spec.ts` files similar to template's one and they would be automatically included in testing.

## Licence

MIT
