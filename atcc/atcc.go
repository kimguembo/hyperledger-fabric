package main

import (
	"encoding/json"
	"fmt"
	"log"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

type SmartContract struct {
	contractapi.Contract
}

type Asset struct {
	ID 				string		`json:"ID"`
	CoinName		string 		`json:"coinName` 
	Price			int			`json:"price"`
	Number			float64		`json:"number"`
}

func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error{
	assets := []Asset{
		{ID: "asset1", CoinName: "Bitcoin", Price : 69555000, Number: 0.23},
		{ID: "asset2", CoinName: "Ada", Price : 1220, Number: 200},
		{ID: "asset3", CoinName: "Ripple", Price : 515, Number: 600},
		{ID: "asset4", CoinName: "Bora", Price : 354, Number: 1200},
		{ID: "asset5", CoinName: "MovieBloc", Price : 14, Number: 10000},
	}

	for _, asset := range assets {
		assetJSON, err := json.Marshal(asset)
		if err != nil {
			return err
		}

		err = ctx.GetStub().PutState(asset.ID,assetJSON)
		if err != nil{
			return fmt.Errorf("failed to put to world state. %v", err)
		}
	}

	return nil
}

func (s *SmartContract) CreateAsset(ctx contractapi.TransactionContextInterface, id string, coinName string, price int, number float64) error {
	exists, err := s.AssetExists(ctx, id)
	if err != nil {
		return err
	}
	if exists {
		return fmt.Errorf("the asset %s already exists", id)
	}

	asset := Asset{
		ID:			id,
		CoinName:	coinName,
		Price: 		price,
		Number:		number,
	}
	assetJSON, err := json.Marshal(asset)
	if err != nil{
		return err
	}

	return ctx.GetStub().PutState(id, assetJSON)
}

func (s *SmartContract) ReadAsset(ctx contractapi.TransactionContextInterface, id string) (*Asset, error) {
	assetJSON, err := ctx.GetStub().GetState(id)
	if err != nil {
		return nil, fmt.Errorf("failed to read from world state: %v",err)
	}
	if assetJSON == nil {
		return nil, fmt.Errorf("the asset %s does not exist", id)
	}

	var asset Asset
	err = json.Unmarshal(assetJSON, &asset)
	if err != nil{
		return nil, err
	}

	return &asset, nil
}

func (s *SmartContract) UpdateAsset(ctx contractapi.TransactionContextInterface, id string, coinName string, price int, number float64) error {
	exists, err := s.AssetExists(ctx, id)
	if err != nil {
		return err
	}
	if !exists {
		return fmt.Errorf("the asset %s does not exist", id)
	}

	asset := Asset{
		ID:			id,
		CoinName:	coinName,
		Price: 		price,
		Number:		number,
	}
	assetJSON, err := json.Marshal(asset)
	if err != nil {
		return err
	}

	return ctx.GetStub().PutState(id, assetJSON)
}

func (s *SmartContract) DeleteAsset(ctx contractapi.TransactionContextInterface, id string) error{
	exists, err := s.AssetExists(ctx, id)
	if err != nil {
		return err
	}
	if !exists {
		return fmt.Errorf("the asset %s does not exist", id)
	}

	return ctx.GetStub().DelState(id)
}

func (s *SmartContract) AssetExists(ctx contractapi.TransactionContextInterface, id string) (bool, error) {
	assetJSON, err := ctx.GetStub().GetState(id)
	if err != nil {
		return false, fmt.Errorf("failed to read from world state: %v", err)
	}

	return assetJSON != nil, nil
}

func (s *SmartContract) GetAllAssets(ctx contractapi.TransactionContextInterface) ([]*Asset, error){
	resultsIterator, err := ctx.GetStub().GetStateByRange("", "")
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	var assets []*Asset
	for resultsIterator.HasNext(){
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return nil,err
		}

		var asset Asset
		err = json.Unmarshal(queryResponse.Value, &asset)
		if err != nil {
			return nil, err
		}
		assets = append(assets, &asset)
	}

	return assets, nil
}

func main() {
	assetChaincode, err := contractapi.NewChaincode(&SmartContract{})
	if err != nil {
		log.Panicf("Error creating asset-transfer-basic chaincode: %v", err)
	}

	if err := assetChaincode.Start(); err != nil {
		log.Panicf("Error starting asset-transfer-basic chaincode: %v", err)
	}
}