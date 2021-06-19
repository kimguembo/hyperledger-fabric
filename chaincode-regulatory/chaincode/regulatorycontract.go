package chaincode

import (
	"encoding/json"
	"fmt"
	"time"
	"strconv"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// "time"
// "strconv"

// SmartContract provides functions for managing an Asset
type RegulatoryContract struct {
	contractapi.Contract
}


type Account struct {
	ID             string `json:"ID"`
	Name		   string `json:"name"`
	Balance 	   int 	  `json:"balance"`	
}

type usageHistory struct {
	ID 			   string `json:"ID"`
	Receiver 	   string `json:"receiver"`
	Price		   int 	  `json:"price"`
	Date		   string `json:"date"`
	Sender 		   string `json:"sender"`
}

func (s *RegulatoryContract) InitAccount(ctx contractapi.TransactionContextInterface) error {

	accounts := []Account{
		{ID: "0", Name: "Shinhan-Main", Balance: 0},
		{ID: "1", Name: "Shinhan-Sub", Balance: 0},
	}

	for _, account := range accounts {
		accountJSON, err := json.Marshal(account)
		if err != nil {
			return err
		}

		err = ctx.GetStub().PutState(account.ID, accountJSON)
		if err != nil {
			return fmt.Errorf("failed to put to world state. %v", err)
		}
	}

	return nil
}

func (s *RegulatoryContract) ReadAccount(ctx contractapi.TransactionContextInterface, id string) (*Account, error) {
	accountJSON, err := ctx.GetStub().GetState(id)

	if err != nil {
		return nil, fmt.Errorf("failed to read world state: %v", err)
	}
	if accountJSON == nil {
		return nil, fmt.Errorf("the asset %s does not exist", id)
	}

	var account Account
	err = json.Unmarshal(accountJSON, &account)

	if err != nil {
		return nil, err
	}

	return &account, nil
}

func (s *RegulatoryContract) UpdateAccount(ctx contractapi.TransactionContextInterface, id string, balance int) error {
	account, err := s.ReadAccount(ctx, id)
	if err != nil {
		return err
	}

	account.Balance = account.Balance + balance
	accountJSON, err := json.Marshal(account)
	if err != nil {
		return err
	}
	s.TransferHistory(ctx, "Central Bank", id, balance)
	return ctx.GetStub().PutState(id, accountJSON)
}

func (s *RegulatoryContract) UpdateSendBalance(ctx contractapi.TransactionContextInterface, id string, rec string, balance int) error {
	account, err := s.ReadAccount(ctx, id)
	if err != nil {
		return err
	}

	account.Balance = account.Balance - balance
	accountJSON, err != json.Marshal(account)
	if err != nil {
		return err
	}

	s.TransferHistory(ctx, id, rec, balance)
}

func (s *RegulatoryContract) AccountExist(ctx contractapi.TransactionContextInterface, id string) (bool, error) {
	accountJSON, err := ctx.GetStub().GetState(id)
	if err != nil {
		return false, fmt.Errorf("failed to read from world state: %v", err)
	}

	return accountJSON != nil, nil
}

func (s *RegulatoryContract) ReadAccount(ctx contractapi.TransactionContextInterface, id string) (*Account, error) {
	accountJSON, err := ctx.GetStub().GetState(id)
	if err != nil {
		return nil, fmt.Errorf("failed to read from world state: %v", err)
	}
	if accountJSON == nil {
		return nil, fmt.Errorf("the asset %s does not exist", id)
	}

	var account Account
	err = json.Unmarshal(accountJSON, &account)
	if err != nil {
		return nil, err
	}

	return &account, nil
}

func (s *RegulatoryContract) ReadTransferHistory(ctx contractapi.TransactionContextInterface) ([]*usageHistory, error) {
	historyJSON, err := ctx.GetStub().GetStateByRange("", "")
	if err != nil {
		return nil, err
	}
	defer historyJSON.Close()
	var historys []*usageHistory
	for historyJSON.HasNext() {
		queryResponse, err := historyJSON.Next()
		
		if err != nil {
			return nil, err
		}
		var history usageHistory
		err = json.Unmarshal(queryResponse.Value, &history)
		if err != nil {
			return nil, err 
		}
		historys = append(historys, &history)
	}
	return historys, nil
}

func (s *RegulatoryContract) TransferHistory(ctx contractapi.TransactionContextInterface, rec string, sen string, price int) error {
	history, err := s.ReadTransferHistory(ctx)
	if err != nil {
		return err
	}
	id := strconv.Itoa((len(history)+1))
	now := time.Now()
	customTime := now.Format("2006-01-02 15:04")
	his := usageHistory{
		ID:			id,
		Receiver:   rec,
		Price:		price,
		Date:		customTime,
		Sender:		sen,
	}
	hisJSON, err := json.Marshal(his)
	if err != nil {
		return err
	}
	return ctx.GetStub().PutState(id, hisJSON)
}